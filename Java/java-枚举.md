---
layout: post
title: Java枚举
date: 2016-08-26 21:50:04
categories: Java
---
Java枚举的简单分析，话说技术博客不应该是炫技的地方了吗？怎么变成了知识备忘的地方了？
<!-- more -->

分析方法：枚举的简单使用，内置方法，高级使用。

## 枚举的简单使用

创建一个enum时，编译器会为你生成一个相关的类，这个类继承自`java.lang.Enum`。每个枚举的项，都可以看成是Enum类的一个实例。

### 枚举值的比较

```java
Key k1 = Key.CC;
Key k2 = Key.PEPELU;
System.out.println("k1==k2?" + (k1 == k2));
```

output:

```
k1==k2?false
```

编译器重新定义了枚举比较时的`==`号操作符，当使用`==`操作符比较enum实例时，会默认提供`equals()`和`hashCode()`方法。枚举中的项都是编译器自动生成的实例，所以不用担心空指针问题。

可以把枚举看成是一个有着类似于class的struct，内部有着自己的内置方法与实现，重写了一些继承自Object的方法，内部成员可以像class中的静态变量那样使用`.`操作符访问，并且返回一个成员的实例，但是这个实例的创建与方法的重写都是编译器做的。

### 枚举是不能被继承的

```java
//这样是不被允许的
enum Key {CC, PEPELU, ALLEN}
enum SubKey extends Key {}
```

### 向枚举中添加新方法

```java
enum Orz {
    WEST("west"), NORTH(), EAST("east"), SOUTH("this is", "south");
    private String description;
    Orz() {
    }
    Orz(String description) {
        this.description = description;
    }
    Orz(String str0, String str1) {
        this.description = str0 + "," + str1;
    }
    private String getDescription() {
        return description;
    }
}
```

自定义枚举方法需要在枚举实例后面加`;`符号，然后再添加自定义的方法和属性，如果在实例前添加，编译器会报错。函数是可以重载的，但构造函数不可以使用除了`private`之外的访问修饰符，因为枚举实例只可以有编译器创建，在其他任何地方创建枚举实例都会报错。

在class内部创建enum，枚举中的访问权限会被忽略，全部为public，即使设置为`private`也没用，在同一个包下，`private`有用，`protected`没用，相当于public，不同包名下，是有`public`可以访问。

### 在switch中使用枚举

```java
enum Key {CC, PEPELU, ALLEN}
void fun(Key key) {
    switch (key) {
        case CC:
            System.out.println("cc");
            break;
        case PEPELU:
            System.out.println("pepelu");
            break;
    }
}
```

case中可以直接是Key的实例。要是想要在case中使用return，编译器会抱怨缺少default，要添加default或者case覆盖所有枚举实例。

## 内置方法

### Enum.values()和Enum#ordinal()

Enum.values()方法返回enum实例的数组，数组元素的顺序是其在枚举中声明的顺序；Enum#ordinal()方法返回枚举元素在声明中的次序。

```java
enum Key {CC, PEPELU, ALLEN}
System.out.println("enum#values() index:" + Key.values()[0]);
for (Key k : Key.values()) {
    //输出枚举成员k在Key中的排序，从0开始
    System.out.println(k + " ordinal:" + k.ordinal());
}
```

output:

```
enum#values() index:CC
CC ordinal:0
PEPELU ordinal:1
ALLEN ordinal:2
```
