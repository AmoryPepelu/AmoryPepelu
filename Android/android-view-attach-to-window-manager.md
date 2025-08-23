---
layout: post
title: View直接贴到WindowManager上
date: 2016-09-01 22:25:45
categories: Android
---
除了在layout布局文件中添加View，在只有Activity的情况下还可以通过直接向WindowManager上贴图的方式向界面上添加控件。
<!--more-->
```java
public class FloatView {

    /**
     * 窗口布局参数
     */
    private WindowManager.LayoutParams mFloatBallParams;

    private ImageView mImageView;

    private WindowManager mWindowManager;

    private Context mContext;

    public FloatView(Context context) {
        mContext = context;
        initFloatBallParams(mContext);
    }

    /**
     * 获取悬浮球的布局参数
     */
    private void initFloatBallParams(Context context) {
        mFloatBallParams = new WindowManager.LayoutParams();
        mFloatBallParams.flags = mFloatBallParams.flags
                | WindowManager.LayoutParams.FLAG_WATCH_OUTSIDE_TOUCH
                | WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL
                | WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE;
        mFloatBallParams.dimAmount = 0.2f;

//		mFloatBallParams.type = WindowManager.LayoutParams.TYPE_SYSTEM_ALERT;

        mFloatBallParams.height = WindowManager.LayoutParams.WRAP_CONTENT;
        mFloatBallParams.width = WindowManager.LayoutParams.WRAP_CONTENT;

        mFloatBallParams.gravity = Gravity.LEFT | Gravity.TOP;
        mFloatBallParams.format = PixelFormat.RGBA_8888;
        // 设置整个窗口的透明度
        mFloatBallParams.alpha = 1.0f;
        // 显示悬浮球在屏幕左上角
        mFloatBallParams.x = 0;
        mFloatBallParams.y = 0;
        mWindowManager = (WindowManager) context.getSystemService(Context.WINDOW_SERVICE);
    }

    /**
     * 获取状态栏高度
     *
     * @return
     */
    public int getStatusBarHeight() {
        int result = 0;
        int resourceId = mContext.getResources().getIdentifier("status_bar_height", "dimen",
                "android");
        if (resourceId > 0) {
            result = mContext.getResources().getDimensionPixelSize(resourceId);
        }
        return result;
    }

    /**
     * 贴图片
     *
     * @param resourceId 图片的资源id
     * @param x          宽度
     * @param y          高度
     */
    public void createImageView(int resourceId, int x, int y) {
        mImageView = new ImageView(mContext);
        mImageView.setImageBitmap(BitmapFactory.decodeResource(mContext.getResources(), resourceId));
        mFloatBallParams.x = x;
        mFloatBallParams.y = y;
    }

    /**
     * 添加图片
     */
    public void addImageView() {
        mWindowManager.addView(mImageView, mFloatBallParams);
    }

    /**
     * 隐藏图片
     */
    public void dismissFloatView() {
        mWindowManager.removeView(mImageView);
    }

    /**
     * 添加事件监听
     *
     * @param listener
     */
    public void setOnClickListener(View.OnClickListener listener) {
        mImageView.setOnClickListener(listener);
    }

    /**
     * 返回图片实例
     *
     * @return
     */
    public ImageView getImageView() {
        return mImageView;
    }

    /**
     * 更新
     */
    public void updateWindowManager() {
        mWindowManager.updateViewLayout(mImageView, mFloatBallParams);
    }
}
```

## 使用

* 创建

```java
FloatView mFloatView;
mFloatView = new FloatView(this);
int floatHeight = mFloatView.getStatusBarHeight();
mFloatView.createImageView(R.drawable.bjm_gf_switch_account_float_image_view, 0, floatHeight);
```

* 贴图

```java
mFloatView.addImageView();
```

* 移除

```java
mFloatView.dismissFloatView();
```

## 注意点

* TYPE_SYSTEM_ALERT 参数
谨慎使用`mFloatBallParams.type = WindowManager.LayoutParams.TYPE_SYSTEM_ALERT`，添加`TYPE_SYSTEM_ALERT`类型后，需要配置权限` <uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW" />`，ok后可以在任意APP的显示界面显示一个view，但这个在Android 6.0以后是不被允许的，需要用户手动设置权限。没有此参数时，添加的View只会在当前Activity的显示界面中展示，跳到其他Activity后，添加的View会和Activity的ContentView一样被隐藏。

* FloatView 实例的创建
FloatView的实例需要在Activity创建之后被创建，不然会报

```
java.lang.RuntimeException: Unable to instantiate activity ComponentInfo:
java.lang.IllegalStateException: System services not available to Activities before onCreate()
```
