---
title: Java格式化说明符
date: 2016-10-10 23:09:48
tags: Java
categories: Java
---
## 基本语法

`%[argument_index$][flags][width][.precision]conversion`
<!--more-->
* flags：对齐方式，默认右对齐，想要左对齐的话，添加`-`。
* width：最小尺寸，不够时会添加空格。
* precision：最大尺寸，用于String时，表示打印String输出字符的最大数量；用于浮点数时，表示小数部分要显示的位数（默认是6位），多则舍入，少则补齐；整数没有小数部分，所以precision用于整数会引发异常。
<!--more-->
```java
public void formatTest() {
    Formatter formatter = new Formatter(System.out);

    //左对齐15位，右对齐5位，右对齐10位
    formatter.format("%-15s|%5s|%10s\n", "pepelu", "CC", "biubiu");

    //右对齐15位，只取要打印的字符串的前2位,
    //precision大于要打印的字符串时不会报错，
    //等于0时打印15位空格，小于0时报错
    formatter.format("%15.2s\n", "pepelu");

    //15位浮点数，保留两位小数:
    formatter.format("%15.2f", 6.2);
    //15位浮点数，默认小数位数：6
    formatter.format("%15f\n", 6.2);

    formatter.format("%c",'上');
}
```

output：

```
pepelu         |   CC|    biubiu
             pe
           6.20
       6.200000
上
```

## String.format()

Read The Fucking Source Code !

```java
public static String format(String format, Object... args) {
    return new Formatter().format(format, args).toString();
}
```

## 类型转换字符

* d：整数类型
* c：Unicode字符
* b：Boolean值
* s：String
* f：浮点数（十进制）
* e：浮点数（科学计数）
* x：整数
* h：散列码（十六进制）
* %：字符“%”

《Thinking in Java》读书笔记
