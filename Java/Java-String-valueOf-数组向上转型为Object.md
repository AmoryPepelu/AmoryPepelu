---
title: Java-String-valueOf-数组向上转型为Object
date: 2017-01-07 22:58:55
categories: Java
tags: Java
---
将一串String转为byte数组，然后再用String.valueOf()转回字符串。
<!-- more -->

```java
void testValueOf() {
    String s = "hello,bitch";
    byte[] bytes = s.getBytes(Charset.forName("UTF-8"));
    System.out.println(String.valueOf(bytes));
}
```

好像是对的，编译器也没有报错，运行一下，输出：`[B@28d93b30`。嗯，这分明是个对象！而且toString也无法奈何它。String哪里去了呢？

看下String.valueOf()这个方法:

```java
public static String valueOf(Object obj)
public static String valueOf(char data[])
public static String valueOf(char data[], int offset, int count)
public static String valueOf(boolean b)
public static String valueOf(char c)
public static String valueOf(int i)
public static String valueOf(long l)
public static String valueOf(float f)
public static String valueOf(double d)
```

仔细一看，是没有`valueOf(byte[] bytes)`的，那么就是向上转型了，`byte[]`会转成什么呢？会转成`Object`。

<!--more-->

测试：

```java
void f1(Object obj) {
    System.out.println("obj");
}
```

调用：

```java
byte[] bytes0 = new byte[12];
f1(bytes0);

byte[][] bytes1 = new byte[1][2];
f1(bytes1);
```

结果：

```
obj
obj
```

这是为何？原因：数组也是对象，而对象的父类是Object，所以数组可以向上转型为Object。

我对对象的理解：对象是保存在堆上的一块连续或者不连续的一块内存区域，拥有方法和属性，对象名相当于一个指向该内存区域的指针，通过对象名（该指针）可以访问到对象的方法和属性。

数组也有自己的类型：

```java
byte[] bytes0 = new byte[12];
byte[][] bytes1 = new byte[1][2];

System.out.println(bytes1 instanceof byte[][]);
// System.out.println(bytes1 instanceof byte[]); //错误
System.out.println(bytes1 instanceof Object);
```

output:

```
true
true
```

二维数组是不可以转为一维数组的，但可以向上转型为Object。

回到开头，要怎样把byte[]数组转为String呢？

```java
String s = "hello,bitch";
byte[] bytes = s.getBytes(Charset.forName("UTF-8"));
System.out.println(new String(bytes, Charset.forName("utf-8")));
```

要说为什么？当然是因为String的构造函数有针对byte[]数组的重载啦。

```java
public String(byte bytes[], Charset charset) {
    this(bytes, 0, bytes.length, charset);
}
```

搅局者`Object[] obj`

添加方法：

```java
void f1(Object obj) {
    System.out.println("obj");
}

void f1(byte[] bytes) {
    System.out.println("bytes");
}

void f1(Object[] obj){
    System.out.println("obj []");
}
```

问题1：一维数组的重载顺序？

```java
byte[] bytes0 = new byte[12];
f1(bytes0);
```

答案是：f1(byte[] bytes) -> f1(Object obj)，不能转为：f1(Object[] obj)。

也就是说：`Object[] objects = bytes0;`这句代码是错误的。原因？解释？bytes0的父对象Object，Object[] 不在byte[] 的继承体系内。

问题2：二维数组的重载顺序？

```java
byte[][] bytes1 = new byte[1][2];
f1(bytes1);
```

答案：f1(Object[] obj) -> f1(Object obj)

可以看出：`Object[]` 至少是 `byte[][]` 的一个父类型之一。

原因：`byte[][]`是由一维数组`byte[]`组合而成的数组，`byte[]`可以向上转型为`Object`，那么，再套一层数组不就是`Object[]`了吗，而`Object[]`又是对象，所以又是Object。

那么，既然如此，如何写多维数组的重载方法？答案是：不写。

只用一个Object就可以了。

不规范写法：

```java
void f1(Object obj) {
    if (obj instanceof byte[]) {
        System.out.println("byte[]");
    } else if (obj instanceof byte[][]) {
        System.out.println("byte[][]");
    }
}
```

规范写法：

```java
void f1(Object obj) {
    if (obj instanceof byte[][]) {
        System.out.println("byte[][]");
    } else if (obj instanceof byte[]) {
        System.out.println("byte[]");
    }
}
```

一维数组在前的写法在byte数组里面也是可以的，但不推荐，为什么呢？因为仅当数组为基本类型数组时，这种写法才是正确的，如果是对象数组也这么写，那么就不会走到二维的判断里面，因为数组的协变，或者说是向上转型。

```java
Object[] objects = new Object[1][1];
```