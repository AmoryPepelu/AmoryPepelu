---
layout: post
title: Java类加载器
date: 2016-08-21 08:35:43
categories: Java
---
只要是class文件，无论放到哪里都是可以被加载到虚拟机里面的。

<!-- more -->

加载外部类的主要方法是`loadClass`，java的安全机制不允许加载以`java`的包名开头的class文件，每个类都是继承自Object父类的，导致加载类的时候，目标类加载成功，但是父类、或者其他的java官方类由于安全问题加载失败，解决办法是把那些类扔给虚拟机内置的类加载器加载，如何判断哪些类属于java官方类的方法写在`loadClass`中了，只有`loadClass`找不到类时，才去调用`findClass`方法，所以现在的做法是重写`findClass`方法去完成自定义的类加载工作。

## 测试类`LoaderTest.java`

```java
package io.amorypepelu;
public class LoaderTest {
    public void fun() {
        System.out.println("have hun!!");
    }
}
```

被加载的类包名不可以`java`开头，不然会在`defineClass`方法中因为java的安全机制抛出`SecurityException`

```java
private ProtectionDomain preDefineClass(String name,ProtectionDomain pd)
{
    if (!checkName(name))
        throw new NoClassDefFoundError("IllegalName: " + name);

    if ((name != null) && name.startsWith("java.")) {
        throw new SecurityException
            ("Prohibited package name: " +
             name.substring(0, name.lastIndexOf('.')));
    }
    if (pd == null) {
        pd = defaultDomain;
    }

    if (name != null) checkCerts(name, pd.getCodeSource());

    return pd;
}
```

## 类加载器`PepeluClassLoader.java`

继承自：`ClassLoader`

```java
private static final String BASE_CLASS_PATH = "E:\\temp\\classes\\";

@Override
protected Class<?> findClass(String name) throws ClassNotFoundException {
    System.out.println("load class name=" + name);
    String fileName = BASE_CLASS_PATH + name.replace(".", File.separator) + ".class";
    File file = new File(fileName);
    FileInputStream fileInputStream = null;
    try {
        fileInputStream = new FileInputStream(file);
        byte[] b = new byte[fileInputStream.available()];
        fileInputStream.read(b);
        return defineClass(name, b, 0, b.length);
    } catch (FileNotFoundException e) {
        e.printStackTrace();
    } catch (IOException e) {
        e.printStackTrace();
    } finally {
        if (fileInputStream != null) {
            try {
                fileInputStream.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }
    throw new ClassNotFoundException(name);
}
```

这里去加载保存在文件系统中的`LoaderTest.class`文件。

## 执行

```java
public static void main(String[] args) throws Exception {
    PepeluClassLoader pepeluClassLoader = new PepeluClassLoader();
    Class<?> clazz = pepeluClassLoader.loadClass("io.amorypepelu.LoaderTest");
    System.out.println("PepeluClassLoader:obj getClass=" + clazz);
    Object object = clazz.newInstance();
    Method method = clazz.getMethod("fun");
    method.invoke(object);
}
```

输出：

```
PepeluClassLoader:obj getClass=class io.amorypepelu.LoaderTest
have hun!!
```

缺点：无法替换已有的class文件，导致放在别处的class文件没有被加载出来。解决办法是：新开辟另一套class文件的文件结构，在`PepeluClassLoader#loadClass`方法中先判断另一套文件结构中是否存在需要被加载的class文件，如果有就加载另一套文件结构中的class，如果没有就调用父类的类加载器加载class文件，这样既可以达到替换class文件的目的也可以避免由于java安全机制带来的问题。

修改后的`PepeluClassLoader#loadClass`：

```java
@Override
public Class<?> loadClass(String name) throws ClassNotFoundException {
    String fileName = BASE_CLASS_PATH + name.replace(".", File.separator) + ".class";
    File checkFile = new File(fileName);
    System.out.println("load file check file name=" + name);
    if (checkFile.exists()) {
        return findClass(name);
    } else {
        return super.loadClass(name);
    }
}
```

这样是可行的，但每次都用文件是否存在来判断，效率太低了，应该找个更机智的办法。
