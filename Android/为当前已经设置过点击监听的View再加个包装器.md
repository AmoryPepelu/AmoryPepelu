---
title: 为当前已经设置过点击监听的View再加个包装器
date: 2017-07-25 17:37:28
categories: Android
tags: Android
---
当前布局中的控件已经设置了点击监听：OnClickListener，此时要给所有已经设置过监听器的控件加一个点击事件采集，通常方法是在每个控件的OnClickListener里面加代码，但这样要写太多的重复代码，想要从另一个角度解决这个问题。

<!--more-->

## View#setOnClickListener 分析

设置点击事件监听：

```java
Button btn1;
btn1 = (Button) findViewById(R.id.btn1);
btn1.setOnClickListener(new View.OnClickListener() {
    @Override
    public void onClick(View v) {
        Log.i(TAG, "onClick: 1");
    }
});
```

既然把View的点击监听set进去了，能不能再从View中取到这个监听呢？能取到的话，就可以处理一下这个回调了。

看看 View#setOnClickListener 干了什么

```java
public void setOnClickListener(@Nullable OnClickListener l) {
    if (!isClickable()) {
        setClickable(true);
    }
    //很关键
    getListenerInfo().mOnClickListener = l;
}

//这个方法是View类私有的，包访问级别
ListenerInfo getListenerInfo() {
    //先判断mListenerInfo是否为空
    if (mListenerInfo != null) {
        return mListenerInfo;
    }
    mListenerInfo = new ListenerInfo();
    return mListenerInfo;
}
```

ListenerInfo 类中持有众多接口的引用，都是和View点击、触摸事件有关的。

```java
static class ListenerInfo {
    ...
    //之前set的OnClickListener就保存在这里
    public OnClickListener mOnClickListener;
    ...
}
```

## 获取 ListenerInfo 中的 mOnClickListener

### 使用动态代理，hook View 的 setOnClickListener

可行性分析：

1. 动态代理要依赖接口，setOnClickListener方法不是实现接口中的方法，是View自身的方法，不可行。
2. 即使把View hook出来，也要把View的hook对象再嵌进去，比较麻烦。

废弃。

### 使用反射

逆向思考一下，点击事件响应是在什么时候？先全局搜一下 mOnClickListener.onClick(View) 在哪里调用了。

用到的地方有两处：

```java
public boolean callOnClick() {
    ListenerInfo li = mListenerInfo;
    if (li != null && li.mOnClickListener != null) {
        li.mOnClickListener.onClick(this);
        return true;
    }
    return false;
}

public boolean performClick() {
    final boolean result;
    final ListenerInfo li = mListenerInfo;
    if (li != null && li.mOnClickListener != null) {
        playSoundEffect(SoundEffectConstants.CLICK);
        li.mOnClickListener.onClick(this);
        result = true;
    } else {
        result = false;
    }

    sendAccessibilityEvent(AccessibilityEvent.TYPE_VIEW_CLICKED);
    return result;
}
```

再在View类中搜一下，这两个方法在哪里用到了，callOnClick，这个方法并没有用到，倒是performClick这个方法，到处都是，看注释performClick这个方法才是View点击响应的真正处理者。

再逆向思考一下，要想获得View set进去的OnClickListener，要先获得ListenerInfo对象

要想获得ListenerInf对象，就要调用View的getListenerInfo()方法，但这个方法并不是随便就能访问的。

于是乎：

```java
View view;
Class cls = Class.forName("android.view.View");
Method method = cls.getDeclaredMethod("getListenerInfo");

method.setAccessible(true);
Object obj = method.invoke(view);

Field filed = obj.getClass().getField("mOnClickListener");
View.OnClickListener originClickListener = (View.OnClickListener) filed.get(obj);
```

只要取得控件的对象，就可以取到mOnClickListener的引用了。

封装一下，搞个静态代理，加点内容，然后在嵌进去。

```java
/**
* 遍历contentView，寻找其中设置过点击监听的控件
* 此方法一定要保证在View#setOnClickListener之后调用
* 否则取到的OnClickListener是null
*
* @param contentView
*/
void checkViewToSetClickListenerHook(View contentView) {
    if (contentView instanceof ViewGroup) {
        ViewGroup vg = (ViewGroup) contentView;
        int count = vg.getChildCount();

        for (int i = 0; i < count; i++) {
            View v = vg.getChildAt(i);
            checkViewToSetClickListenerHook(v);
        }
    } else {
        setHook(contentView);
    }
}

/**
* 为设置过点击监听的控件加个包装器
*
* @param view
*/
void setHook(View view) {
    try {
        Class cls = Class.forName("android.view.View");
        Method method = cls.getDeclaredMethod("getListenerInfo");

        method.setAccessible(true);
        Object obj = method.invoke(view);

        Field filed = obj.getClass().getField("mOnClickListener");
        View.OnClickListener originClickListener = (View.OnClickListener) filed.get(obj);

        if (originClickListener == null) {
            return;
        }
        //fix:一个页面重复打开会添加过个回调的bug
        if (originClickListener instanceof ViewClickWrapper) {
            return;
        }

        ViewClickWrapper wrapper = new ViewClickWrapper(originClickListener);
        filed.set(obj, wrapper);
    } catch (Exception e) {
        e.printStackTrace();
    }
}

class ViewClickWrapper implements View.OnClickListener {
    View.OnClickListener onClickListener;

    public ViewClickWrapper(View.OnClickListener onClickListener) {
        this.onClickListener = onClickListener;
    }

    @Override
    public void onClick(View v) {
        if (onClickListener == null) {
            return;
        }
        onClickListener.onClick(v);

        //有些View虽然设置了onClick，但没有设置id
        int id = v.getId();
        if (id == 0xffffffff) {
            Log.i(TAG, "onClick: view id is 0xffffffff , this view do not have @+id property in xml");
            return;
        }
        //有些View是使用View#setID动态设置id的
        try {
            Log.i(TAG, "current click name is :" + v.getResources()
                    .getResourceEntryName(v.getId()));
        } catch (Resources.NotFoundException e) {
            Log.i(TAG, "view id is :" + id + ",Unable to find resource ID");
        }
    }
}
```

[源码地址](https://github.com/AmoryPepelu/AndroidHunter/tree/master/app/src/main/java/github/amorypepelu/view_click)

