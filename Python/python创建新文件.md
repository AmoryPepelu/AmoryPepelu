---
layout: post
title: Python创建新文件
date: 2016-08-17 22:56:06
categories: Python
---
之前一直在想能把命令行使用到什么地步，因此弄了一个用命令行创建新文件的工具，但突然有一天我在想：命令行并不方便啊，如果什么事都让给命令行来做，还要那些编程语言做什么，编程语言不就是为了能更方便地做事情才被发明出来的吗。凑巧最近在看Python方面的书籍，于是考虑用Python做个小工具玩玩。

<!-- more -->

## 创建文件

用Python创建文件：`open(fileName,'w')`，如果没有这个文件的话会自动创建一个新文件。

## 获取当前时间

导入`time`模块：`time.strftime("%Y-%m-%d", time.localtime())`

## 创建md文件到指定目录

为了更少的修改代码，给其增加json配置文件

* 读取json文件

```python
with open('config.json') as configFile :
    config = json.load(configFile)
```

获取到的`config`对象是一个字典，只要用key就可以取到value的值了，但为了防止json文件中配置错误，增加异常处理：

```python
try:
    value = config[key]
except KeyError:
    print('the key = ' + key + ' is not defined in the config.json')
```

* 为md文件写入head

其实整个创建md文件的过程用jekyll一条命令就可以解决，但安装jekyll太费事了，相对而言Python真是业界良心。

## 完整代码

```python
/** CreateNewFile.py */
import os
import time
import json

def ResolveJsonValueFromConfig(key = ''):
    if(key==None or len(key)==0):
        print("-----key is None or length = 0--------")
        return ''
    with open('config.json') as configFile :
        config = json.load(configFile)
        try:
            value = config[key]
        except KeyError:
            print('the key = ' + key + ' is not defined in the config.json')
            return ''
        return value

outPutPath = ResolveJsonValueFromConfig('outPutPath')
print('outPutPath = ' + outPutPath)
fileName = time.strftime("%Y-%m-%d", time.localtime())
fileSuffix = ResolveJsonValueFromConfig('fileSuffix')
print('fileSuffix = ' + fileSuffix)

if(len(outPutPath) > 0):
    os.chdir(outPutPath)
f = open(fileName + '.' + fileSuffix,'w')
f.write('---\n')
f.write('layout: post\n')
f.write('title: \n')
f.write('date: ' + time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()) + '\n')
f.write('categories: \n')
f.write('---\n')
f.close()
```

## 配置文件:` config.json`

```json
{
    "fileSuffix" : "md",
    "outPutPath" : "../../_posts"
}
```

* fileSuffix: 文件后缀名

* outPutPath: 输出文件的目录

## 再懒一点

不想每次都跑到py文件的目录下执行Python，用bat文件增加一点情趣。

```bash
cd tools/create-new-file
python CreateNewFile.py
```
