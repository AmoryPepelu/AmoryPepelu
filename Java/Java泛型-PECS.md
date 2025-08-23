---
title: Java泛型-PECS
date: 2016-11-27 15:58:18
categories: Java
tags: Java
---
Producer extends and Consumer super。这里说的角度是集合的角度，当从集合中取数据，此时集合可以被看作生产者，应该使用`extends`：`List<? extends T>`;当向集合中插入数据，此时可以把集合看作消费者，应该使用`super`：`List<? super T>`；当对插入和读取不做要求时，既不要使用 `extends` 也不要使用 `super` 。
<!--more-->
`List<? extends T>` 表示集合中的数据是T或是T类型的子类型，每个类型都表现为T类型，当向其中插入数据时，你无法得知List中究竟是T还是T的哪个子类型，无法和要插入的数据匹配类型，所以无法向其中插入数据。

取数据时，每个元素都是T或T的子类，因此可以向上转型为T。

`List<? super T>` 表示集合中的数据都是T的父类，超类。取数据时无法得知取出的数据是T哪一代的父类，因此无法向下转型为T。插入数据时，因为得知集合中的数据类型最低也是T，所以只要是T或者T的子类型都可以插入进去。

```Java
public class Animal {}

public class Cat extends Animal {}

public class CoffeeCat extends Cat {}
```

取数据，此时集合作为生产者 Producer：

```Java
List<? extends Cat> list1 = new ArrayList<>();
Cat cat1 = list1.get(0);
Animal animal1 = list1.get(0);
```

插入数据，此时集合作为消费者 Consumer:

```Java
List<? super Cat> list2 = new ArrayList<>();
list2.add(cat);
list2.add(coffeeCat);
```

参考：

[What is PECS](http://stackoverflow.com/a/2723538)
