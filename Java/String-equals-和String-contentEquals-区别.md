---
title: 'String#equals()和String#contentEquals()区别'
date: 2016-10-09 23:32:49
tags: Java
categories: Java
---
`String#equals()`不仅比较这个字符串的内容还检查另一个被比较的对象是否是String类型或String类型的子类，`String#contentEquals()`只比较两者的内容是否相同，不检查被比较对象的类型。

<!--more-->

```java
String s = "hello world";
StringBuilder sb = new StringBuilder("hello world");

System.out.println(s.equals(sb));
System.out.println(s.contentEquals(sb));
```

output：
```
false
true
```

看`String#equals()`方法：
```java
public boolean equals(Object anObject) {
    if (this == anObject) {
        return true;
    }
    //如果不是String继承体系的类相比较，都返回false
    if (anObject instanceof String) {
        String anotherString = (String)anObject;
        int n = value.length;
        if (n == anotherString.value.length) {
            char v1[] = value;
            char v2[] = anotherString.value;
            int i = 0;
            while (n-- != 0) {
                if (v1[i] != v2[i])
                    return false;
                i++;
            }
            return true;
        }
    }
    return false;
}
```

`String#contentEquals()`源码，`String#contentEquals(StringBuffer sb)`和`String#contentEquals(CharSequence cs)`一样的：

```java
public boolean contentEquals(CharSequence cs) {
    // Argument is a StringBuffer, StringBuilder
    if (cs instanceof AbstractStringBuilder) {
        if (cs instanceof StringBuffer) {
            synchronized(cs) {
               return nonSyncContentEquals((AbstractStringBuilder)cs);
            }
        } else {
            return nonSyncContentEquals((AbstractStringBuilder)cs);
        }
    }
    // Argument is a String
    if (cs instanceof String) {
        return equals(cs);
    }
    // Argument is a generic CharSequence
    char v1[] = value;
    int n = v1.length;
    if (n != cs.length()) {
        return false;
    }
    for (int i = 0; i < n; i++) {
        if (v1[i] != cs.charAt(i)) {
            return false;
        }
    }
    return true;
}
```

再看`nonSyncContentEquals()`方法：

```java
private boolean nonSyncContentEquals(AbstractStringBuilder sb) {
    char v1[] = value;
    char v2[] = sb.getValue();
    int n = v1.length;
    if (n != sb.length()) {
        return false;
    }
    for (int i = 0; i < n; i++) {
        if (v1[i] != v2[i]) {
            return false;
        }
    }
    return true;
}
```

比较String类型与`String`,` StringBuilder`, `StringBuffer`, `CharBuffer`,等类型内容的相等性使用`String#contentEquals()`。

参考：

[Difference between String#equals and String#contentEquals methods](http://stackoverflow.com/a/6476612)