---
layout: post
title:  命令行编译Java
date:   2016-04-15 09:00:00
categories: Java
---
命令行编译Java
<!--more-->
## Java代码：

```java
/* a.java */
package com.pepelu.test;
public class a{
	public static void main(String[] args){
		System.out.println("hello shell");
	}
}
```

类名要和文件名一致，不然会报错（找不到类啊什么的）。

## 编译，生成class文件：

```bash
javac -target 1.7 -source 1.7 -bootclasspath E:\environment\adt\sdk\platforms\android-20\android.jar -d E:\workspace\EclipseAndroid\test_pkg_out\classes E:\workspace\EclipseAndroid\HelloWorld\src\com\example\helloworld\*.java E:\workspace\EclipseAndroid\test_pkg_out\RFile\com\example\helloworld\R.java
```

 -target <版本>               生成特定 VM 版本的类文件（可以不要）

 -source 1.7                  要求編譯器檢查使用的語法不超過指定的版本

 -bootclasspath <路径>        Bootstrap類別載入器（Class loader）

 -d <目录>                    指定存放生成的类文件的位置，生成package的目录结构

 -sourcepath <路径>           指定查找输入源文件的位置

 因为Android目前不支持jdk1.8，所以如果使用的jdk的版本大于1.7，编译Java文件时要加入：-target 1.7 ，JDK8預設的-target與-source都是1.8，-target在指定時，值必須大於或等於-source，所以在上面，若只指定-target為1.7，就會無法通過編譯，因為-source仍是預設值1.8。

简化版：

```
javac -d  E:\workspace\java\temp  E:\workspace\java\temp\a.java
```

-d <目录>                   指定存放生成的类文件的位置，生成package的目录结构

-sourcepath <路径>          指定查找输入源文件的位置

如果把命令行光标移到所在目录，则文件名前的目录可以省略，如果有多个文件，用空格分隔

```
javac -d classes a.java b.java
```

自动生成对应包名的文件目录

更简化版：

```
javac -d . JavaFileName
```

在当前目录生成package结构的class文件。

## 执行a.class

执行前把shell定位到package开始目录

```
java com.pepelu.test.a
```

保存输出：

```
java com.pepelu.test.a >save.data
```

把输出保存到save.data文件中。

## 打包jar：

jar cvf [生成jar的名称.jar] [列出class文件]   //若有多个用空格隔开

把控制台定位到package名对应的起始目录

```
jar -cvf a.jar .
```

"." 代表当前目录，文件名可加目录

`升级版`：在任意目录打指定目录的jar包

```
 jar -cvf a.jar -C E:\workspace\java\temp\classes .
```

-C： 先执行 `cd E:\workspace\java\temp\classes` , 再执行 `jar -cvf a.jar .`,但*.jar文件保存在shell光标所在文件目录。

## 执行jar包中的class文件

```
java -cp a.jar com.pepelu.test.a
```

-cp : 进入到jar包内执行 com.pepelu.test.a

## 引用其他jar包，编译：

```java
/* b.java */
package net.pepelu.test;
public class b{
	public String f1(){
		System.out.println("this is b.class");
		return "no bb";
	}
}

/* c.java */
package com.pepelu.test;
import net.pepelu.test.b;
public class c{
	public static void main(String[] args){
		b _b=new b();
		_b.f1();
		System.out.println("------------------");
	}
}
```

编译：

```
//生成class文件，b.java,c.java 同时编译：
javac -d classes a.java b.java

//分文件编译，先编译b.java生成jar包，再编译a.java
javac -cp jarFileName JavaFileName -d classes
```

## 引用其他jar包，执行

执行：执行前把shell定位到package开始目录

```
//CMD:
java -cp b.jar;c.jar; com.pepelu.test.c

//PowerShell:
java -cp 'b.jar;c.jar;' com.pepelu.test.c
```

jar包最后要加“；”

jar包顺序可变

在PowerShell中，把 `b.jar;`加单引号或双引号，因为PowerShell是面向对象的命令行，所以会把b.jar看做是一个文件对象，而Java需要接收的是一个jar文件地址字符串，所以要加引号把b.jar;转为字符串“;”号必须加。
http://stackoverflow.com/questions/4685184/powershell-run-java-process-problem

## 多jar包：

假设有个程序的启动方法在test.java里
运行Java程序是java test，但是如果要引用其他jar包，网上大多数的方法都是java -classpath xx.jar test
但是jar很多的话，就要一个一个写上去，非常麻烦。而且jar包可能经常变
现在用以下一句就能解决问题，假设jar包都放在lib文件夹里

编译：

```
//CMD：
javac -Djava.ext.dirs=lib test

//PowerShell :
javac '-Djava.ext.dirs=lib' com.pepelu.test.c
```

执行：

```
//CMD：
java -Djava.ext.dirs=lib test

//PowerShell :
java '-Djava.ext.dirs=lib' com.pepelu.test.c
```

注意：要JDK1.6以上才可以

## 打包，配置 META-INF

```
/* MANIFEST.MF */
Manifest-Version: 1.0  
Created-By: pepelu  
Class-Path: com.pepelu.test
Main-Class: com.pepelu.test.a
(此处为空行)
```

第一行指定清单的版本，若无，则JDK默认生成：Manifest-Version: 1.0

第二行指明创建的作者，若无，则JDK默认生成Created-By: 1.6.0_22(Sun Microsystems Inc.)

第三行指定主类所在类路径

第四行指明程序运行的主类

在文件最后要加一行空行

打包：

```
 jar -cvfm a.jar MANIFEST.MF -C classes .
```

-m : 指定MANIFEST.MF文件

如果MANIFEST.MF末尾不加空行，则要重新指定主类所在类路径

```
 jar -cvfme a.jar MANIFEST.MF com.pepelu.test.a -C classes .
```

运行：

```
java -jar a.jar
```

## 补充：

主函数mian是可以传参的：

```
public static void main(String[] args)
```

命令行执行：

```
java com.pepelu.test.a blabla
```
