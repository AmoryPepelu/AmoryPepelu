---
title: Java方法签名与方法块
date: 2016-10-25 20:49:02
tags: Java
categories: Java
---

java 学习笔记
<!-- more -->
## Java方法签名

Java的方法签名不包括返回值。

```java
public Object fuck() {
    return new Object();
}

//wrong !!
public String fuck() {
    return "fuck";
}
```

Java的方法签名包括：方法名和参数。不包括方法返回值。所以由于`fuck()`这个函数已经定义，第二次定义就失败了。

但可以在子类中重写（overwrite）该方法。

```java
/** Base.java **/
public class Base {
    public Object fuck() {
        return new Object();
    }
}

/** Sub.java **/
public class Sub {
    @Override
    public String fuck() {
        return "fuck";
    }
}
```

子类重写父类方法，方法签名一致，返回值不同，称之为：协变返回类型。


## 方法块

```java
public class Program {
    {
        System.out.println("begin class A");
        class A {
            {
                System.out.println("that's ok");
            }

            private void f() {
                System.out.println("in f()");
            }
        }
        new A().f();

//        new Program().fuck();
    }

    {
        System.out.println("another block");
    }

    static {
        System.out.println("static block");
    }

    public Program() {
        System.out.println("this is program");
    }

    public void fuck() {
        System.out.println("I don't give a fuck");
    }

    public static void main(String[] args) {
        Program program = new Program();
    }
}
```

先看输出：

```
static block
begin class A
that's ok
in f()
another block
this is program
```

总体思路是:

1. static方法块在类加载时执行
2. 非static方法块在类实例化之前执行
3. 方法块执行顺序与在代码中的顺序有关
4. 不可以在方法块里面定义方法，但可以定义类

如果在方法块里面实例化类，会导致：java.lang.StackOverflowError，相当于递归般的创建对象但没有终止出口，所以`public void fuck()`这个方法始终没有执行到。

可以在方法块里面执行类实例的方法：

```java
{
    fuck();
}
```

HA! HA!