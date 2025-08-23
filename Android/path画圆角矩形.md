---
title: path画圆角矩形
date: 2019-01-16 18:02:19
tags: View
categories: Android
---

使用 `path.addRoundRect()` 方法，基本使用是这些，可以做一些深度的定制。

<!-- more -->

``` java

class RoundRectView : View {

​    private val roundRectPath = Path()

​    private val pathRect = RectF()

​    private val pathPaint = Paint()

​    init {

​        pathPaint.isAntiAlias = true

​    }

​    @JvmOverloads

​    constructor(context: Context, attrs: AttributeSet? = null, defStyleAttr: Int = 0)

​            : super(context, attrs, defStyleAttr)

​    override fun onDraw(canvas: Canvas?) {

​        super.onDraw(canvas)

​        pathRect.set(width / 2f, 0f, width / 2f + 100, height.toFloat())

​        roundRectPath.reset()

​        roundRectPath.addRoundRect(pathRect, Utils.dip2px(context, 10f).toFloat(), Utils.dip2px(context, 10f).toFloat(), Path.Direction.CW)

​        roundRectPath.fillType = Path.FillType.WINDING

​        pathPaint.style = Paint.Style.FILL

​        pathPaint.color = ActivityCompat.getColor(context, R.color.color_FD5056)

​        canvas?.drawPath(roundRectPath, pathPaint)

​    }

}

```

