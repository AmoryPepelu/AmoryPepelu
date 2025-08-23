---
layout: post
title:  Java-当继承遇到反射
date:   2016-04-12 09:00:00
categories: Java
---
inherit-and-reflect,起因：使用EventBus库时，只是在父类中注册了监听事件，把this传递过去了：EventBus.getDefault().register(this)，子类中并没有注册监听事件，但在响应时调用的却是子类中的响应方法，EventBus是用反射来获取注册监听器的类的方法表然后调用相关方法的，因此写了个继承与反射的例子来分析一下。
<!-- more -->

```java
/* A.java */
public class A {
	public void foo() {
	}
}
```

```java
/* B.java */
public class B extends A {

	public void foo() {}

	public void foo2() {}

	public void foo3() {}
}
```

```java
public class Program {

	public static void main(String[] args) {
		A obj = new B();
		Class<?> clazz = obj.getClass();
		Method[] methods = clazz.getMethods();
		for (Method method : methods) {
			System.out.println(method.getName());
		}
	}
}
```

### 输出：

```
foo
foo3
foo2
wait
wait
wait
equals
toString
hashCode
getClass
notify
notifyAll
```

这里得到的方法列表是B类中的方法。

### 解释：

因为 A obj = new B() , obj的实际类型是B，obj调用getClass()方法时，由于链接时的动态绑定，obj.getClass()方法被重新定向到了类B#getClass()方法的方法调用入口，所以obj.getClass()实际执行的是B#getClass()函数，因此得到的是B的Class实例。
因此 clazz.getMethods() 得到的自然是类B的方法表了。

## 关于"this"：

在类A中添加方法：

```java
public void fuck() {
	System.out.println(this);
	System.out.println(this.getClass().getName());
}
```

在main()方法中调用fuck():

```
A obj = new B();
obj.fuck();
```

### 输出：

```
test.demo.B@15db9742
test.demo.B
```

在A类中的this被重新定向到了B类的实例。

### 解释：

类B继承类A，同对getClass()函数的分析一样，类B在编译时自动拷贝了类A中的所有方法，类B没有显示地重写fuck()函数，因此在类B内也有一份与类A中fuck()函数相同的fuck()函数的拷贝。在执行obj.fuck()时，由于链接时的动态绑定obj.fuck()方法被重新定向到了类B#fuck()方法的方法调用入口，所以obj.fuck()，实际执行的是B#fuck()函数，因此A.java文件中fuck()函数的this是B的实例也就不足为奇了，因为obj.fuck()方法不是调用类A而是调用类B中的fuck()。
