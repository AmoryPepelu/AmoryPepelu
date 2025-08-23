---
title: TabLayout定制
date: 2018-10-27 09:30:33
tags: View
categories: Android
---

解决的问题：

* 添加自定义tab
* 设置tab间间距
* 点击事件处理、tab选中和选中事件回调
* 点击TabLayout空白处无响应以及再点击Tab仍无响应问题处理
* tab点击背景效果处理
* 设置 indicator 宽度和里面内容宽度一致

<!-- more -->

### 添加自定义tab

布局：

```xml
<android.support.design.widget.TabLayout
    android:id="@+id/tab_layout"
    android:layout_width="0dp"
    android:layout_height="wrap_content"
    android:layout_marginStart="10dp"
    android:layout_marginEnd="10dp"
    app:layout_constraintBottom_toBottomOf="parent"
    app:layout_constraintLeft_toRightOf="@+id/tv_get_ticket_tips"
    app:layout_constraintRight_toLeftOf="@+id/iv_more"
    app:layout_constraintTop_toTopOf="parent"
    app:tabBackground="@color/color_white"
    app:tabIndicatorHeight="0dp"
    app:tabPadding="0dp"
    app:tabPaddingEnd="10dp"
    app:tabPaddingStart="0dp" />
```

Java：

```java
binding.tabLayout.setTabMode(TabLayout.MODE_SCROLLABLE);

for (String tip : data) {
    TabLayout.Tab tab = binding.tabLayout.newTab();
    tab.setCustomView(generateTextView(tip));
    binding.tabLayout.addTab(tab);
}

/**
 * 构建textview
 *
 * @param tips
 * @return
 */
private TextView generateTextView(String tips) {
    TextView tv = new TextView(getContext());
    tv.setText(tips);
    tv.setGravity(Gravity.CENTER);
    tv.setBackground(ActivityCompat.getDrawable(getContext(), R.mipmap.bg_get_ticket_tip));
    tv.setTextColor(ActivityCompat.getColor(getContext(), R.color.view_color_FD5056));
    tv.setTextSize(TypedValue.COMPLEX_UNIT_SP, 13f);
    int pt = AndroidUtils.dip2px(getContext(), 1.5f);//paddingTop
    int pl = AndroidUtils.dip2px(getContext(), 8.5f);//paddingLeft
    tv.setPadding(pl, pt, pl, pt);
    return tv;
}
```

效果

![](/images/tablayout.1.jpg)

可滑动

![](/images/tablayout.2.jpg)

### tab间间距问题

tab之间有默认间距，可以在xml中处理：

* 设置底边提示高度为0： `app:tabIndicatorHeight="0dp"`  

```xml
app:tabPadding="0dp"
app:tabPaddingEnd="10dp"
app:tabPaddingStart="0dp"
```

或者使用代码处理：

```java
private void resetTabPadding() {
    try {
        //拿到tabLayout的mTabStrip属性
        Class<?> tabLayoutClz = TabLayout.class;
        Field mTabStripField = tabLayoutClz.getDeclaredField("mTabStrip");
        mTabStripField.setAccessible(true);
        LinearLayout mTabStrip = (LinearLayout) mTabStripField.get(binding.tabLayout);
        int dp10 = AndroidUtils.dip2px(getContext(), 10);
        for (int i = 0; i < mTabStrip.getChildCount(); i++) {
            View tabView = mTabStrip.getChildAt(i);
            //TextView mTextView = (TextView) mTextViewField.get(tabView);
            tabView.setPadding(0, 0, 0, 0);
            tabView.setBackground(null);
        }
    } catch (Exception e) {
        //ignore
        e.printStackTrace();
    }
}
```

### tab选中事件处理

添加选中回调

```java
tabLayout.addOnTabSelectedListener(this);
@Override
public void onTabSelected(TabLayout.Tab tab) {}

@Override
public void onTabUnselected(TabLayout.Tab tab) {}

@Override
public void onTabReselected(TabLayout.Tab tab) {}
```

设置默认选中tab ->在添加tab时：需要在添加tab之前添加回调

```java
tabLayout.addTab(tab, true);
```

### tab 选中效果处理

tab选中时背景默认会有一个阴暗变化，可以使用 `app:tabBackground="@color/color_white"` 屏蔽

###设置 indicator 宽度和里面内容宽度一致

```kotlin
tabLayout.tabMode = TabLayout.MODE_SCROLLABLE
//add tabs

/**
 * @param externalMargin 整体tab边距
 * @param internalMargin 内部tab边距
 */
fun wrapTabIndicatorToTitle(tabLayout: TabLayout, externalMargin: Int, internalMargin: Int) {
    val tabStrip = tabLayout.getChildAt(0)
    if (tabStrip is ViewGroup) {
        val childCount = tabStrip.childCount
        for (i in 0 until childCount) {
            val tabView = tabStrip.getChildAt(i)
            //set minimum width to 0 for instead for small texts, indicator is not wrapped as expected
            tabView.minimumWidth = 0
            // set padding to 0 for wrapping indicator as title
            tabView.setPadding(0, tabView.paddingTop, 0, tabView.paddingBottom)
            // setting custom margin between tabs
            if (tabView.layoutParams is ViewGroup.MarginLayoutParams) {
                val layoutParams = tabView.layoutParams as ViewGroup.MarginLayoutParams
                if (i == 0) {
                    // left
                    settingMargin(layoutParams, externalMargin, internalMargin)
                } else if (i == childCount - 1) {
                    // right
                    settingMargin(layoutParams, internalMargin, externalMargin)
                } else {
                    // internal
                    settingMargin(layoutParams, internalMargin, internalMargin)
                }
            }
        }

        tabLayout.requestLayout()
    }
}

private fun settingMargin(layoutParams: ViewGroup.MarginLayoutParams, start: Int, end: Int) {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
        layoutParams.marginStart = start
        layoutParams.marginEnd = end
        layoutParams.leftMargin = start
        layoutParams.rightMargin = end
    } else {
        layoutParams.leftMargin = start
        layoutParams.rightMargin = end
    }
}
```

[java code](https://stackoverflow.com/a/44026386)

### 综合实例

在一个自定义的ViewGroup中添加多个View，子View满屏可滑动，可以使用RecyclerView、TabLayout、HorizontalScrollView 来做，这里选取 TabLayout。

按照上面的属性做好后，发现如果让TabLayout充满整个布局，在子Tab不满的情况下，点击TabLayout空白区域，再点击子Tab，点击事件消失，而且点击TabLayout空白区域也不会触发点击事件，原因是TabLayout继承HorizontalScrollView，而HorizontalScrollView中重写了点击事件分发的方法却没有调用performClick()方法，因此HorizontalScrollView无法响应点击事件。

处理方法：

1. 让TabLayout布局尽可能小，只需包含所含Tab即可，并且最大不能超过规定的区域，这样可以避免TabLayout多余空白区域被点击到，在TabLayout上套一层FrameLayout，TabLayout宽度设置为wrap_content，FrameLayout宽度设置为充满父容器
2. 响应每个Tab的点击事件，并调用该自定义ViewGroup的performClick() 方法，把点击响应交个自定义容器上的点击回调处理

```xml
<?xml version="1.0" encoding="utf-8"?>
<layout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    xmlns:tools="http://schemas.android.com/tools">

    <android.support.constraint.ConstraintLayout
        android:layout_width="match_parent"
        android:layout_height="75dp"
        android:descendantFocusability="blocksDescendants"
        app:drShadow="@{`all`}">

        <TextView
            android:id="@+id/tv_get_ticket_tips"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:layout_marginStart="15dp"
            android:layout_marginLeft="15dp"
            android:gravity="center"
            android:text="领券："
            android:textColor="@color/color_8E8E8E"
            android:textSize="14sp"
            app:layout_constraintBottom_toBottomOf="parent"
            app:layout_constraintLeft_toLeftOf="parent"
            app:layout_constraintTop_toTopOf="parent" />

        <FrameLayout
            android:id="@+id/fl_container"
            android:layout_width="0dp"
            android:layout_height="wrap_content"
            android:layout_marginStart="10dp"
            android:layout_marginEnd="10dp"
            app:layout_constraintBottom_toBottomOf="parent"
            app:layout_constraintLeft_toRightOf="@+id/tv_get_ticket_tips"
            app:layout_constraintRight_toLeftOf="@+id/iv_more"
            app:layout_constraintTop_toTopOf="parent">

            <com.rabbit.doctor.widget.DRTabLayout
                android:id="@+id/tab_layout"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                app:tabBackground="@color/color_white"
                app:tabIndicatorHeight="0dp"
                app:tabPadding="0dp"
                app:tabPaddingEnd="10dp"
                app:tabPaddingStart="0dp" />
        </FrameLayout>

        <ImageView
            android:id="@+id/iv_more"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:layout_marginEnd="15dp"
            android:layout_marginRight="15dp"
            android:src="@mipmap/arrow"
            app:layout_constraintBottom_toBottomOf="parent"
            app:layout_constraintRight_toRightOf="parent"
            app:layout_constraintTop_toTopOf="parent" />
    </android.support.constraint.ConstraintLayout>
</layout>
```

```java
public class GetTicketLayout extends DRFrameLayout implements TabLayout.OnTabSelectedListener {
    private LayoutGetTicketBinding binding;

    public GetTicketLayout(Context context) {
        super(context);
    }

    public GetTicketLayout(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    public GetTicketLayout(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
    }

    @Override
    protected void init(Context context) {
        super.init(context);
        binding = DataBindingUtil.inflate(LayoutInflater.from(getContext()), R.layout.layout_get_ticket, this, true);
        binding.tabLayout.setTabMode(TabLayout.MODE_SCROLLABLE);
        binding.tabLayout.addOnTabSelectedListener(this);
    }

    public void setData(List<String> data) {
        binding.tabLayout.removeAllTabs();
        if (ArrayUtils.isEmptyList(data)) {
            return;
        }
        for (String tip : data) {
            TabLayout.Tab tab = binding.tabLayout.newTab();
            tab.setCustomView(generateTextView(tip));
            binding.tabLayout.addTab(tab, false);
        }
    }

    /**
     * 构建textview
     *
     * @param tips
     * @return
     */
    private TextView generateTextView(String tips) {
        TextView tv = new TextView(getContext());
        tv.setText(tips);
        tv.setGravity(Gravity.CENTER);
        tv.setBackground(ActivityCompat.getDrawable(getContext(), R.mipmap.bg_get_ticket_tip));
        tv.setTextColor(ActivityCompat.getColor(getContext(), R.color.view_color_FD5056));
        tv.setTextSize(TypedValue.COMPLEX_UNIT_SP, 13f);
        int pt = AndroidUtils.dip2px(getContext(), 1.5f);//paddingTop
        int pl = AndroidUtils.dip2px(getContext(), 8.5f);//paddingLeft
        tv.setPadding(pl, pt, pl, pt);
        return tv;
    }

    @Override
    public void onTabSelected(TabLayout.Tab tab) {
        //当选中tab时，触发view 点击事件
        performClick();
    }

    @Override
    public void onTabUnselected(TabLayout.Tab tab) {

    }

    @Override
    public void onTabReselected(TabLayout.Tab tab) {

    }
}

```

