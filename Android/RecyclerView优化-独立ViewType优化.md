---
title: RecyclerView优化-独立ViewType优化
date: 2019-04-01 10:17:11
tags: RecyclerView
categories: Android
---

项目中为了在一个页面展示更多的功能模块，把页面做成长列表的样式，选择使用RecyclerView实现长列表，为的是可以复用其中的某些模块。

<!-- more -->

带来的局限性是：有些列表项是全列表唯一的，而且这种列表项还有不少，每次页面从屏幕外展示到屏幕中都会调用 `onBindViewHolder()` 虽然也可以使用 `NestedScrollView` 但这样一来就没法复用 RecyclerView 中的重复项了。对于全列表唯一的ViewType，如果只在创建时赋一次值就好了。

记录列表的ViewType,如果是全列表唯一，则只执行一次刷新，其他时候直接服用Holder里面的ItemView缓存就好，并且可以强制刷新。

实现：

Adapter

```java
public abstract class StandAloneRvAdapter<VH extends RecyclerView.ViewHolder> extends RecyclerView.Adapter<VH> {
    private static final String TAG = "rv_adapter";
    private ViewTypeManager viewTypeManager;

    @Override
    public void onAttachedToRecyclerView(@NonNull RecyclerView recyclerView) {
        super.onAttachedToRecyclerView(recyclerView);
        Log.i(TAG, "onAttachedToRecyclerView: ");
        viewTypeManager = new ViewTypeManager(this);
        registerAdapterDataObserver(new StandAloneAdapterObserver(viewTypeManager, this));
    }

    public abstract VH getViewHolder(@NonNull ViewGroup parent, int viewType);

    public abstract void refreshItemView(@NonNull VH holder, int position);

    @NonNull
    @Override
    public final VH onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        Log.i(TAG, "onCreateViewHolder: " + getItemCount());
        viewTypeManager.resolveViewType();
        return getViewHolder(parent, viewType);
    }

    @Override
    public final void onBindViewHolder(@NonNull VH holder, int position) {
        boolean shouldBindViewHolder = viewTypeManager.shouldBindViewHolder(holder, position);
        Log.i(TAG, "onBindViewHolder: itemCount=" + getItemCount() + ",shouldBindViewHolder=" + shouldBindViewHolder);
        if (!shouldBindViewHolder) {
            return;
        }
        //refresh view
        refreshItemView(holder, position);
    }
}
```

ViewTypeManager

```java
public class ViewTypeManager {
    private static final int Default_Type = -1;
    private static final int Stand_Alone = 1;
    private static final int Not_Special = 2;
    private static final int Force_Refresh = 3;
    private static final int Bloody_New = 4;

    private SparseIntArray itemTypeSpa = new SparseIntArray();

    private RecyclerView.Adapter adapter;

    public ViewTypeManager(RecyclerView.Adapter adapter) {
        this.adapter = adapter;
    }

    public void clear() {
        itemTypeSpa.clear();
    }

    /**
     * 判断ViewType是否唯一，就两种情况：唯一 或者 不唯一，不用判断是否是 其他类型
     * 必须一次性全部检查完，如果依次检查，第一个会被漏掉
     */
    public void resolveViewType() {
        if (itemTypeSpa.size() != 0) return;
        resolveViewType(0, adapter.getItemCount());
    }

    public void resolveViewType(int start, int count) {
        for (int i = start; i < start + count; i++) {
            int viewType = adapter.getItemViewType(i);
            int viewTypeSpaValue = itemTypeSpa.get(viewType, Default_Type);
            if (viewTypeSpaValue == Default_Type) {
                itemTypeSpa.put(viewType, Bloody_New);
            } else if (viewTypeSpaValue != Not_Special) {//加一个判断，如果viewTypeSpaValue已经是Not_Special则无需重复赋值
                itemTypeSpa.put(viewType, Not_Special);
            }
        }
    }

    /**
     * 是否应该调用bind
     *
     * @param holder
     * @param position
     * @return
     */
    public boolean shouldBindViewHolder(RecyclerView.ViewHolder holder, int position) {
        boolean ret = true;
        int viewType = holder.getItemViewType();
        int viewTypeSpaValue = itemTypeSpa.get(viewType);
        switch (viewTypeSpaValue) {
            case Stand_Alone:
                ret = false;
                break;
            case Bloody_New: {
                //设置独立身份
                itemTypeSpa.put(position, Stand_Alone);
                break;
            }
            case Force_Refresh: {
                //恢复独立身份
                itemTypeSpa.put(position, Stand_Alone);
                break;
            }
            default:
                break;
        }
        return ret;
    }
}
```

AdapterDataObserver

```java
public class StandAloneAdapterObserver extends RecyclerView.AdapterDataObserver {
    private static final String TAG = "rv_adapter";
    private ViewTypeManager manager;
    private RecyclerView.Adapter adapter;

    public StandAloneAdapterObserver(ViewTypeManager manager, RecyclerView.Adapter adapter) {
        this.manager = manager;
        this.adapter = adapter;
    }

    public void onChanged() {
        Log.i(TAG, "onChanged: " +adapter. getItemCount());
        manager.clear();
        manager.resolveViewType();
    }

    public void onItemRangeChanged(int positionStart, int itemCount) {
        Log.i(TAG, "onItemRangeChanged: " + adapter.getItemCount());
    }

    public void onItemRangeChanged(int positionStart, int itemCount, @Nullable Object payload) {
        this.onItemRangeChanged(positionStart, itemCount);
    }

    public void onItemRangeInserted(int positionStart, int itemCount) {
        Log.i(TAG, "onItemRangeInserted: " + adapter.getItemCount());
        manager.resolveViewType(positionStart, itemCount);
    }

    public void onItemRangeRemoved(int positionStart, int itemCount) {
        Log.i(TAG, "onItemRangeRemoved: " + adapter.getItemCount());
        manager.clear();
        manager.resolveViewType();
    }

    public void onItemRangeMoved(int fromPosition, int toPosition, int itemCount) {
        Log.i(TAG, "onItemRangeMoved: " + adapter.getItemCount());
    }
}
```