---
title: 两个为null的String相加结果是什么？
date: 2016-11-09 22:22:48
categories: Java
tags: Java
---
先说结论，得到的结果是：`nullnull`
<!-- more -->

## String类型相加会重载‘+’运算符

```java
String a = null;
String b = null;
String s = a + b;
System.out.println(s);

output:
nullnull
```
<!--more-->
## StringBuilder#appen(String)

```java
@Override
public StringBuilder append(String str) {
    super.append(str);
    return this;
}
```

## 看super.append(String)

```java
public AbstractStringBuilder append(String str) {
    if (str == null)
        return appendNull();
    int len = str.length();
    ensureCapacityInternal(count + len);
    str.getChars(0, len, value, count);
    count += len;
    return this;
}
```

## 看appendNull()方法

```java
private AbstractStringBuilder appendNull() {
    int c = count;
    ensureCapacityInternal(c + 4);
    final char[] value = this.value;
    value[c++] = 'n';
    value[c++] = 'u';
    value[c++] = 'l';
    value[c++] = 'l';
    count = c;
    return this;
}
```

果然是append "null"。
