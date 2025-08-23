---
layout: post
title: 不可思议的java
date: 2016-08-31 21:11:13
categories: Java
---
收集一些难以置信的java代码。
<!--more-->
## 两个null相加

```java
String a = null, b = null;
String c = a + b;
if ("nullnull".equals(c)) {
    System.out.println("nullnull equals c");
}
System.out.println("c=" + c);
```

output:

```
nullnull equals c
c=nullnull
```

解释:字符串相加会被编译器解释为：

```java
s0 = new StringBuilder().append(s0).append(s1).toString();
```

## 对编译时常量的理解

```java
String a = "abc";
String b = "ab" + "c";
System.out.println(a == b);
```

结果是相等。"abc"、"ab"、"c"在Java里都是String类型的编译时常量。当+运算符的左右两个操作数都是编译时常量时，这个+表达式也会被认为是编译时常量表达式。内容相同的String类型编译时常量会被intern为同一个对象，所以a与b都引用了这个对象，要检查它们是否引用相等，自然得到true。

转自[RednaxelaFX在知乎的回答](https://www.zhihu.com/question/50111592)
