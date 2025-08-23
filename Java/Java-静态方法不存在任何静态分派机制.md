---
title: Java中静态方法不存在任何静态分派机制
date: 2017-01-03 20:14:16
categories: Java
tags: Java
---

静态方法不存在任何静态分派机制，当一个程序调用静态方法、字段时，要被调用的方法、字段都是在编译时刻被选定的，而这种选定是基于修饰符的编译期类型而做出的，修饰符的编译期类型就是我们给出的方法调用表达式原点左边的名字。

不要用类实例来调用静态方法。

<!-- more -->

```java
class Dog {
    public static void bark() {
        System.out.println("woof");
    }
}

class Basenji extends Dog {
    public static void bark() {
        //do nothing
    }
}
```

```java
Dog dog = new Dog();
dog.bark();

Dog nipper = new Basenji();
nipper.bark();

Basenji basenji = new Basenji();
basenji.bark();
```

输出

```
woof
woof

```
