---
title: SpannableString的使用
date: 2016-11-09 22:00:40
categories: Android
tags: Android
---
## SpannableString

```java
private static final String alpha = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
SpannableString spannableString = new SpannableString(alpha);
ForegroundColorSpan span = new ForegroundColorSpan(Color.parseColor("#0099EE"));
spannableString.setSpan(span, 1, 12, Spanned.SPAN_INCLUSIVE_EXCLUSIVE);
textVew.setText(spannableString);
```

范围是[BCDEFGHIJKL]，无论是`Spanned.SPAN_INCLUSIVE_EXCLUSIVE`还是`Spanned.SPAN_INCLUSIVE_INCLUSIVE`都是前包后不包。
<!--more-->
* ForegroundColorSpan : 设置前景色
* BackgroundColorSpan : 背景色
* RelativeSizeSpan : 相对文字大小，实例化时设定文字比例 `new RelativeSizeSpan(1.2f)`
* StrikethroughSpan : 中划线
* UnderlineSpan : 下划线
* SuperscriptSpan : 上标
* SubscriptSpan : 下标
* StyleSpan : 设置文字风格，粗体 `StyleSpan styleSpan_B  = new StyleSpan(Typeface.BOLD)`、斜体 `new StyleSpan(Typeface.ITALIC)`
* ImageSpan : 插入图片 `new ImageSpan(drawable)`
* ClickableSpan : 加入点击事件

```java
ClickableSpan clickableSpan=new ClickableSpan() {
    @Override
    public void onClick(View widget) {

    }
};
```

* URLSpan : 文字中加入超链接
* SpannableStringBuilder : 组合

```java
SpannableString spannableString = new SpannableString(alpha);
ForegroundColorSpan span = new ForegroundColorSpan(Color.parseColor("#0099EE"));
spannableString.setSpan(span, 1, 12, Spanned.SPAN_INCLUSIVE_INCLUSIVE);

SpannableStringBuilder builder = new SpannableStringBuilder(alpha);
builder.append(spannableString);
```

输出：两遍`alpha`，后一个的前景色改变。

整理自：[用SpannableString打造绚丽多彩的文本显示效果](http://www.jianshu.com/p/84067ad289d2)
