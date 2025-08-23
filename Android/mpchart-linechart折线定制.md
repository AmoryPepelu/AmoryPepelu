---
title: mpchart-linechart折线定制
date: 2018-05-29 11:24:39
tags: Android
categories: Android
---
要求：

1. 根据节点性质，选择画虚线还是实线
2. 如果节点数据是0，选择跳过还是从上个非空节点连线过来

画虚实线、不跳过空节点

```java
Entry e1, e2;

e1 = dataSet.getEntryForIndex(mXBounds.min);

if (e1 != null) {

    int j = 0;
    //重置path
    linePath.reset();
    lineDashPath.reset();
    for (int x = mXBounds.min; x <= mXBounds.range + mXBounds.min; x++) {

        e1 = dataSet.getEntryForIndex(x == 0 ? 0 : (x - 1));
        e2 = dataSet.getEntryForIndex(x);

        if (e1 == null || e2 == null) continue;

        //起点
        if (j == 0 && !isEmptyEntry(e2)) {
            j++;
            linePath.moveTo(e2.getX(), e2.getY() * phaseY);
            lineDashPath.moveTo(e2.getX(), e2.getY() * phaseY);
        }

        if (isEmptyEntry(e2)) {
            //当前点是空点  循环
            continue;
        }
        //上一个点是空点,当前点不空,连线
        if (isForecastPoint(e2)) {
            //下一个点是预测点：画虚线
            if (isDrawSteppedEnabled) {
                lineDashPath.lineTo(e2.getX(), e1.getY() * phaseY);
            }
            lineDashPath.lineTo(e2.getX(), e2.getY() * phaseY);
            linePath.moveTo(e2.getX(), e2.getY() * phaseY);
        } else {
            //下一个点是正常点：画直线
            if (isDrawSteppedEnabled) {
                linePath.lineTo(e2.getX(), e1.getY() * phaseY);
            }
            linePath.lineTo(e2.getX(), e2.getY() * phaseY);
            lineDashPath.moveTo(e2.getX(), e2.getY() * phaseY);
        }
    }

    if (j > 0) {
        //画直线
        trans.pathValueToPixel(linePath);
        mRenderPaint.setColor(dataSet.getColor());
        canvas.drawPath(linePath, mRenderPaint);

        //画虚线
        trans.pathValueToPixel(lineDashPath);
        mRenderPaint.setPathEffect(new DashPathEffect(new float[]{6, 6}, 6));
        mBitmapCanvas.drawPath(lineDashPath, mRenderPaint);
        mRenderPaint.setPathEffect(null);
    }
}
```

画虚实线、跳过空节点

```java
Entry e1, e2;

e1 = dataSet.getEntryForIndex(mXBounds.min);

if (e1 != null) {

    int j = 0;
    //重置path
    linePath.reset();
    lineDashPath.reset();
    for (int x = mXBounds.min; x <= mXBounds.range + mXBounds.min; x++) {

        e1 = dataSet.getEntryForIndex(x == 0 ? 0 : (x - 1));
        e2 = dataSet.getEntryForIndex(x);

        if (e1 == null || e2 == null) continue;

        //起点
        if (j == 0) {
            j++;
            linePath.moveTo(e1.getX(), e1.getY() * phaseY);
            lineDashPath.moveTo(e1.getX(), e1.getY() * phaseY);
        }

        //做下一个点的处理
        if (isEmptyEntry(e2)) {
            //下一个点是空点:移动到下一个点的位置
            lineDashPath.moveTo(e2.getX(), e2.getY() * phaseY);
            linePath.moveTo(e2.getX(), e2.getY() * phaseY);
        } else if (isEmptyEntry(e1)) {
            //上一个点是空点：移动到下一个点的位置
            lineDashPath.moveTo(e2.getX(), e2.getY() * phaseY);
            linePath.moveTo(e2.getX(), e2.getY() * phaseY);
        } else if (isForecastPoint(e2)) {
            //下一个点是预测点：画虚线
            if (isDrawSteppedEnabled) {
                lineDashPath.lineTo(e2.getX(), e1.getY() * phaseY);
            }
            lineDashPath.lineTo(e2.getX(), e2.getY() * phaseY);
            linePath.moveTo(e2.getX(), e2.getY() * phaseY);
        } else {
            //下一个点是正常点：画直线
            if (isDrawSteppedEnabled) {
                linePath.lineTo(e2.getX(), e1.getY() * phaseY);
            }
            linePath.lineTo(e2.getX(), e2.getY() * phaseY);
            lineDashPath.moveTo(e2.getX(), e2.getY() * phaseY);
        }
    }

    if (j > 0) {
        //画直线
        trans.pathValueToPixel(linePath);
        mRenderPaint.setColor(dataSet.getColor());
        canvas.drawPath(linePath, mRenderPaint);

        //画虚线
        trans.pathValueToPixel(lineDashPath);
        mRenderPaint.setPathEffect(new DashPathEffect(new float[]{6, 6}, 6));
        mBitmapCanvas.drawPath(lineDashPath, mRenderPaint);
        mRenderPaint.setPathEffect(null);
    }
}
```
