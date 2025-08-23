---
title: Python字符串
date: 2016-11-01 20:56:51
categories: Python
tags: Python
---
* Python中的字符串不可变
<!--more-->
## 分割字符串

```python
import re
line = 'asdf fjdk; afed, fjek	,asdf, foo'
data = re.split('\\s',line)
print(data)
```

支持正则，把所有的空格，换行符，制表符都去掉，可以使用`\s`，也可以使用`\\s`，在java里面是`\\s`。

output:

```
['asdf', 'fjdk;', 'afed,', 'fjek', ',asdf,', 'foo']
```

## 常用函数

```
s = 'hello,bitch'

# 以什么开头
s.startswith('hello')

# 以什么结尾
s.endswith('bitch')

# 是否包含‘,’
s.find(',')

# 最后一次出现'h'的位置
s.rfind('h')

# 计算'h'出现的次数
s.count('h')

# 是否都是字母或数字
s.isalnum()

# 删除指定字符，不能删除','是为什么？
s.strip('h')

# 字符串首字母大写
s.capitalize()

# 每个单词的首字母大写
s.title()

# 变大写
s.upper()

# 变小写
s.lower()

# 大小写转化
s.swapcase()

# 排版相关：在指定字符中居中
s.center(30)

# 排版相关：在指定字符中左对齐
s.ljust(30)

# 排版相关：在指定字符中左对齐
s.rjust(30)
```

原字符串不变，返回新字符串。

## 解压序列赋值给多个变量

```python
p = (4,5)
pa ,pb = p
print(pa)
print(pb)
print(pa,pb)
```

在数量上要一致。

output:

```
4
5
4 5
```

使用占位符：

```
p = (4,5,6,7,8)
_,pa ,pb,_,_ = p
print(pa)
print(pb)
print(pa,pb)
```

解压赋值可以用在任何可迭代对象上面，而不仅仅是列表或者元组。包括：字符串，文件对象，迭代器和生成器。

批量赋值，使用 `*` 操作符：

```
record = ('Dave', 'dave@example.com', '773-555-1212', '847-555-1212')
a,b,*c = record
print(a)
print(b)
print(c)
```

output：

```
Dave
dave@example.com
['773-555-1212', '847-555-1212']
```

##　从一个集合中获得最大或者最小的 N 个元素列表

`heapq` 库：

```
heapq.nlargest(n, iterable, key=None) # 取最大的n个数
heapq.nsmallest(n, iterable, key=None) # 取最小的n个数
heapq.heapify(iterable) #排序
```
不懂，key要怎么使用？lambda如何用？

##　索引

```
s = 'hello,bitch'
print(s[6])
```

## 类型转换

使用 `str()` 可将其他数据类型转换为字符串。

## 批量复制

用 `*` ：

```
data = '-' * 12
print(data)
# output :------------
```

## 分片

* s[:] : [0,len(s)]
* s[start:] : [start,len(s)]
* s[:end] : [0,end)
* s[start:end] : [start,end)
* s[start:end:step] : [start,end)，步长为step

1. 如果end长度超出字符串长度，会打印到字符串末尾，不会自动补充。
2. start要先于end出现在字符串中，反之取到的字符串为空字符串，前提是步长为正值

字符串反转：

```
s = 'hello,bitch'
data = s[-1::-1]
print(data)
# output:hctib,olleh
```

## 获取长度:len(container)

## 分割

`split(separator)` 返回值是一个list，只能根据一个限定符分割字符串，分割多个限定符，使用 : `re.split()`

```
>>> line = 'asdf fjdk; afed, fjek,asdf, foo'
>>> import re
>>> re.split(r'[;f]',line)
['asd', ' ', 'jdk', ' a', 'ed, ', 'jek,asd', ', ', 'oo']
```

## 交叉相乘：join

`'123'.join('abc')` output : `'a123b123c'` 

## 替换：replace

替换第一处 `hello` 为 `hi`：

```
s = 'hello,bitch'
s.replace('hello','hi')
```

替换前12处`hello`为`hi`：

```
s = 'hello,bitch,hello,hello'
s.replace('hello','hi',12)
```

## 字符串匹配

```
from fnmatch import fnmatch, fnmatchcase
s = 'hello,bitch'
b1 = fnmatch(s,'llo')
b2 = fnmatch(s,'*llo*')
b3 = fnmatch(s,'*LLO*')
b4 = fnmatchcase(s,'*LLO*')
print(b1)
print(b2)
print(b3)
print(b4)

# output:
# False
# True
# True
# False
```

fnmatch() 函数使用底层操作系统的大小写敏感规则 (不同的系统是不一样的) 来
匹配模式。fnmatchcase()区分大小写。文件名匹配使用glob。