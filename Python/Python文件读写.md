---
title: Python文件读写
date: 2016-10-28 22:33:39
categories: Python
tags: Python
---
二进制文件、压缩文件操作例子很少。
<!--more-->
## 获取帮助信息

```python
help(object)
//such as looking for print() method's help
help(print)
```

## py文件的编码

如果你有用到非ASCII字符，则需要在文件头部进行字符编码的声明：`# code: UTF-8`，或者：`#-*- coding: UTF-8 -*-`

## 读取文本内容

一次性全部读取：

```python
with open('a.json','rt') as f :
	data = f.read()

print(data)
```

分行读取：

```python
with open('a.json','rt') as f :
	for line in f :
		print(line , end = '')
```

## 写入文件

```python
with open('b.txt','wt') as f :
	f.write('a')
	f.write('b')
```

如果文件系统中没有`b.txt`文件，会新建一个`b.txt`文件。

output：

```
ab
```

使用`print()`函数写入数据，把输出重定向到文件中：

```python
with open('b.txt','wt') as f :
	print('c',file=f)
	print('d',file=f)
```

output：

```
c
d
```

使用`wt`会覆盖已有内容，使用`at`则是追加内容，追加时注意，不是换行追加而是在原文件结束的位置追加的。`print`函数默认以换行符结尾，可以使用`print('c',file=f,end='')`修改。

## with语句

使用`with`语句会自动关闭文件，不使用的话可以用：

```python
f = open('b.txt','rt',encoding='utf8')
data = f.read()
print(data)
f.close()
```

## 被操作文件的编码

Python文件读写采用系统默认的编码，可以使用`encoding=''`修改：

```python
open('b.txt','rt',encoding='utf8')
```

如果文件编码结构被破坏，可以使用一个可选参数`errors`来处理：

```python
f = open('b.txt','rt',encoding='ascii',errors='ignore')
data = f.read()
print(data)
f.close()
```

使用`ignore`会忽略错误的字符，使用`replace`即使显示的是一串乱码也会显示。

## 以不同的行结尾或分隔符完成打印

`sep`表示语句间的分隔符，`end`表示以何种符号结尾。

```python
print('pepelu',23,'yui',sep=',',end='')
print('pepelu',23,'yui',sep=';',end='')
print('--------------')
print('pepelu',23,'yui',sep=';',end='!!\n')
print('--------------')
for i in range(5):
    print(i,end=' ')
```

output：

```
pepelu,23,yui
pepelu;23;yui
--------------
pepelu;23;yui!!
--------------
0 1 2 3 4
```

## 读写二进制文件

使用`open`函数的`rb`或`wb`或`xb`对文件进行读写：

```python
#read
with open('b.bin','rb') as f :
	data = f.read()
	print(data)

#write
with open('b.bin','wb') as f :
	f.write(b'hello,bitch')
```

## 对不存在的文件执行写入操作

使用`wt`对文件进行写操作，如果文件不存在，会新建一个文件，使用`xt`对文件执行写操作，如果文件不存在，也会新建文件，而不是终止执行。

```python
with open('c.txt','xt') as f :
	f.write('fuck')
```

## 在字符上执行IO操作

不会创建新文件，但可以把`io.StringIO()`返回的对象当做文件对象来操作。

```python
import io
s = io.StringIO()
s.write('hello,bitch')
# data = s.read(4) 无输出
print(s.getvalue())

f = io.StringIO('another bitch')
print(f.read())
```

output:

```
hello,bitch
another bitch
```

## path库

* os.path.exists()：判断文件是否存在

```python
import os
if not os.path.exists('b.txt'):
	print('b.txt does not exists')
else:
	print('b.txt exists')
```

* path.basename() : 获取文件名(不包括文件目录)，目录名（不包括父目录）
* path.dirname() : 获取文件目录，不包括文件名，字符串文件目录要加`\\`
* path.join() : 链接多个文件目录，除去第一个参数之外，其他参数不能包含盘符
* path.expanduser() : 文件目录前自动扩展用户目录

```python
from os import path
fp = 'E:\\Github\\iPotato\\iDrafts\\b.txt'

data = path.basename(fp)
print(data)

data = path.dirname(fp)
print(data)

data = path.join('tmp','jb',path.basename(fp))
print(data)

data = path.join(path.dirname(fp),'jb',path.basename(fp))
print(data)

data = path.expanduser('~\\data\\b.txt')
print(data)
```

output:

```
E:\Github\iPotato\iDrafts>py a.py
b.txt
E:\Github\iPotato\iDrafts
tmp\jb\b.txt
E:\Github\iPotato\iDrafts\jb\b.txt
C:\Users\John\data\b.txt
```

* path.splitext() : 分割文件名与后缀名

```python
from os import path
fp = 'E:\\Github\\iPotato\\iDrafts\\b.txt'

data = path.splitext(fp)
print(data)

data = path.splitext(fp)[0]
print(data)

data = path.splitext(fp)[1]
print(data)

data = path.splitext(path.basename(fp))[0]
print(data)

data = path.splitext(path.basename(fp))[1]
print(data)
```

output:

```
('E:\\Github\\iPotato\\iDrafts\\b', '.txt')
E:\Github\iPotato\iDrafts\b
.txt
b
.txt
```

## 检测文件是否存在

* path.isfile() : 检测是否是一个文件，返回值：True 或者 False
* path.isdir() : 检测是否是一个目录
* path.islink() : 是否是链接
* path.realpath() :　获取物理存储位置
* path.getsize() : 获取文件大小
* path.getmtime() : 文件修改时间
* path.getctime() : 文件创建时间

获取文件的元数据之前要注意权限检测，使用`os.stat()`。

```python
from os import path
fp = 'E:\\Github\\iPotato\\iDrafts\\b.txt'

data = path.isfile(fp)
print(data)

data = path.isdir(fp)
print(data)

data = path.islink(fp)
print(data)

data = path.realpath(fp)
print(data)

data = path.getsize(fp)
print(data)

data = path.getmtime(fp)
import time
time_data = time.ctime(data)
print(time_data)
```

## 目录列表

* 取指定目录中的文件和目录，列表并输入文件中保存。

```python
import os
fp = 'E:\\Github\\iPotato\\iDrafts'

names = os.listdir(fp)
print(names)

f = open('E:\\Github\\iPotato\\iDrafts\\b.txt','wt',encoding='utf8')
for line in names :
	print(line,file = f)
f.close()
```

遇到一个错误：`Python PermissionError  Permission denied`，是因为之前打开`b.txt`没有关闭。

* 过滤列表中的文件名：`[for ... in ... if...]`

```python
import os
fp = 'E:\\Github\\iPotato\\iDrafts'

names = [name for name in os.listdir(fp) if name.find('a')]
print(names)
```

* 使用`glob`文件名匹配：

找出文件名中包含`a`的文件：

```python
import glob
# 输出包含目录
fp = 'E:\\Github\\iPotato\\iDrafts\\*a*.*'
# 输出不包含目录，工作区间在工程的工作区间
# fp = '*a*.*'
files = glob.glob(fp)
print(files)
```

* 使用`fnmatch` :

```python
from fnmatch import fnmatch
import os
fp = 'E:\\Github\\iPotato\\iDrafts'
files = [name for name in os.listdir(fp) if fnmatch(name,'*.txt')]
print(files)
```

## 文件编码

* 使用`sys.getfilesystemencoding()`获取文件系统编码。

```python
import sys
data = sys.getfilesystemencoding()
print(data)

with open('\xf1v.txt','w') as f :
	f.write('hello,bitch')
```

* 标准输出的编码

```python
import sys
print(sys.stdout.encoding)
```

* 修改标准输出的编码：

```python
import io
sys.stdout = io.TextIOWrapper(sys.stdout.detach(),encoding='utf8')
print(sys.stdout.encoding)
```

* 修改控制台报错：UnicodeEncodeError: 'gbk' codec can't encode character '\xf1' in position 0: illegal multibyte sequence

`print()`函数有局限，使用前添加`sys.stdout = io.TextIOWrapper(sys.stdout.detach(),encoding='utf8')`，改一下编码

```python
import sys
import io
import os
sys.stdout = io.TextIOWrapper(sys.stdout.detach(),encoding='utf8')
with open('\xf1v.txt','w') as f :
	f.write('hello,bitch')

fp = 'F:\\workspace\\python'
def badfilename(filename):
    tmp = filename.encode(sys.getfilesystemencoding(),errors='surrogateescape')
    return tmp

names = os.listdir(fp)
for name in names:
    try:
        print(name)
    except UnicodeEncodeError:
        print(badfilename(name))
```

## 创建临时文件和文件夹

* 创建临时文件

```python
from tempfile import TemporaryFile
with TemporaryFile('w+t') as f:
    f.write('hello,bitch')
    f.write('test')
    f.seek(12)
    data=f.read()
    print(data)
```

使用 `seek()` 跳转到指定文件位置，文本文件使用 `w+t`，二进制文件使用 `w+b`，当临时文件被关闭时，文件已经不存在了。

`TemporaryFile()` 另外还支持跟内置的 `open()` 函数一样的参数 :

```python
with TemporaryFile('w+t', encoding='utf-8', errors='ignore') as f:
```

使用 `NamedTemporaryFile` 创建临时文件，关闭时文件也会被删除，使用 `delete=False` 可防止文件被删除 : `NamedTemporaryFile('w+t',delete=False)`。

```python
from tempfile import NamedTemporaryFile
with NamedTemporaryFile('w+t') as f:
    print(f.name)
```

* 创建临时目录：

在3.2之后有效。

```python
from tempfile import TemporaryDirectory
with TemporaryDirectory() as filename:
    print(filename)
```

## 序列化

* 序列化至文件中

使用 `pickle.dump()` 写入文件中，使用 `pickle.load()` 从文件中读取内容。

```python
import pickle
data = 'hello,bitch'
f = open('a.txt','wb')
pickle.dump(data,f)
f.close()

f = open('a.txt','rb')
data = pickle.load(f)
print(data)
f.close()
```

* 序列化到`string`

```python
import pickle
data = 'hello,bitch'
bstring = pickle.dumps(data)
print(bstring)

tstring = pickle.loads(bstring)
print(tstring)
```

output:

```
b'\x80\x03X\x0b\x00\x00\x00hello,bitchq\x00.'
hello,bitch
```

和json解析一样的。

## os库

查看帮助：

```python
import os
help(os)
help(os.path)
help(os.name)
```
