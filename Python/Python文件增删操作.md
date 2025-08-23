---
title: Python文件操作
date: 2016-10-29 21:31:06
categories: Python
tags: Python
---
Python文件操作
<!--more-->
## 复制

使用 `shutil.copyfile(src,dst)` 函数复制文件：

```python
import shutil
src = 'E:\\Github\\iPotato\\iDrafts\\b.txt'
dst = 'E:\\Github\\iPotato\\iDrafts\\to\\b.txt'
shutil.copyfile(src,dst)
```

`dst` 必须以存在，复制的是文件，不能复制文件夹。复制文件到一个文件夹用 `shutil.copy(src,dst)` :

```python
import shutil
src = 'E:\\Github\\iPotato\\iDrafts\\b.txt'
dst = 'E:\\Github\\iPotato\\iDrafts\\to'
data = shutil.copy(src,dst)
print(data)
```

src必须是文件，不能是目录，dst可以是目录，可以是文件，如果是目录且目录不存在，复制后不会创建新目录，而是以目录名为文件名`to`。

## 删除文件

```python
import os
filename = 'E:\\Github\\iPotato\\iDrafts\\b.bin'
os.remove(filename)
```

## 删除目录

```python
import shutil
pathname = 'E:\\Github\\iPotato\\iDrafts\\to'
shutil.rmtree(pathname)
```

删除`to`文件夹。使用 `os.rmdir("dir")` 不能删除非空目录。

## 重命令

```python
import os
filename = 'E:\\Github\\iPotato\\iDrafts\\b.txt'
os.rename(filename,'t.txt')
```

在 `os.rename(src,dst)`中，`dst`可以是全路径名也可以是文件名，如果`src`是路径名，则修改的就是最底层的文件目录名。

## 移动

```python
import shutil
src = 'E:\\Github\\iPotato\\iDrafts\\b.txt'
dst = 'E:\\Github\\iPotato\\iDrafts\\t\\b.txt'
shutil.move(src, dst)
```

可以移动文件，也可以移动目录，也可以为移动后的文件指定文件名。

## 创建目录

```python
# 创建单级目录
os.mkdir(pathname)

# 创建多级目录
os.makedirs(pathnames)
```
