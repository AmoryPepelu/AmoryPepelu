---
layout: post
title: Java反射
date: 2016-08-28 22:45:40
categories: Java
---
Java反射学习笔记
<!--more-->
## Class#getGenericInterfaces()方法

以数组的形式返回此类中实现的接口的类型：Type[]。

## Class#getGenericSuperclass()方法

获取父类的类型，返回值是Type的实例。

## Type#getTypeName()方法

获取类型名，Type是个接口，Class类实现这个这个接口，得到Class的实例就可以调用该接口。

参考：

[java.lang.Class類](http://tw.gitbook.net/java/lang/java_lang_class.html)
