---
title: 小工具-Python解析AndroidManifest.xml
date: 2016-12-08 21:29:24
tags: Tools
categories: Python
---
目标：解析AndroidManifest.xml，取得其中四大组件的名字，组成一个列表。

<!--more-->

## 把xml文件解析成xml节点形式：

```python
from xml.etree.ElementTree import parse
def getElementTree(filePath):
    with open(filePath, encoding='utf8') as f:
        doc = parse(f)
    return doc
```

使用 `parse` 方法。

## 读取全部组件名

```python
def getSourceActList(doc):
    nodelist = doc.findall('application/activity')
    act_list = []
    for node in nodelist:
        act_list.append(node.get('{http://schemas.android.com/apk/res/android}name'))
    return act_list
```

先用findall方法获取全部activity节点，根节点是manifest，可以用`'application/activity'`取到次级节点的次级节点。

然后用get方法读取activity里面的属性，因为android使用的是 `http://schemas.android.com/apk/res/android`的命名空间：`xmlns:android="http://schemas.android.com/apk/res/android"`，所以要把`android`替换成`http://schemas.android.com/apk/res/android`。

读取service使用：doc.findall('application/service')
读取receiver使用：doc.findall('application/receiver')
读取provider使用：doc.findall('application/provider')

## 与目标文件比对

因为目标文件并不是严格意义上的xml文件，多以不能以xml的形式读取，简单暴力的方法是分成行全部读取，然后做字符串分割。

```python
with open(to_doc_file_path, encoding='utf8') as to_file:
    for line in to_file:
        if 'android:name' in line and 'uses-permission' not in line:
            to_lists.append(line)
to_lists_real = []
for ls in to_lists:
    to_lists_real.append(ls[ls.index('"') + 1:ls.rfind('"'):])
```

`if 'android:name' in line and 'uses-permission' not in line`这里做个判断，把权限隔离。

`ls[ls.index('"') + 1:ls.rfind('"'):]`这里做字符串分片，只读取`""`符号内的字符串。

然后就是两者的比对了，同样暴力操作：

```python
for source_line in source_lists:
    if source_line not in to_lists_real:
        output_file.write(source_line + "\n")
```

把不在其中的组件名写入输出文件中。

全部代码：

```python
# code : utf8
from xml.etree.ElementTree import parse

source_filePath = r'F:\temp\xml\AndroidManifest.xml'
to_doc_file_path = r'F:\temp\xml\a.xml'
output_file_path = r'F:\Project\CheckManifestSources\output.txt'


def getElementTree(filePath):
    with open(filePath, encoding='utf8') as f:
        doc = parse(f)
    return doc


def getSourceActList(doc):
    nodelist = doc.findall('application/activity')
    act_list = []
    for node in nodelist:
        act_list.append(node.get('{http://schemas.android.com/apk/res/android}name'))
    return act_list


def getSourceReceiverList(doc):
    nodelist = doc.findall('application/receiver')
    receiverList = []
    for node in nodelist:
        receiverList.append(node.get('{http://schemas.android.com/apk/res/android}name'))
    return receiverList


def getSourceServiceList(doc):
    nodelist = doc.findall('application/service')
    serviceList = []
    for node in nodelist:
        serviceList.append(node.get('{http://schemas.android.com/apk/res/android}name'))
    return serviceList


def getSourceProviderList(doc):
    nodelist = doc.findall('application/provider')
    providerList = []
    for node in nodelist:
        providerList.append(node.get('{http://schemas.android.com/apk/res/android}name'))
    return providerList


if __name__ == "__main__":
    source_doc = getElementTree(source_filePath)
    source_lists = []
    source_lists.extend(getSourceActList(source_doc))
    source_lists.extend(getSourceReceiverList(source_doc))
    source_lists.extend(getSourceProviderList(source_doc))
    source_lists.extend(getSourceServiceList(source_doc))
    to_lists = []
    with open(to_doc_file_path, encoding='utf8') as to_file:
        for line in to_file:
            if 'android:name' in line and 'uses-permission' not in line:
                to_lists.append(line)
    to_lists_real = []
    for ls in to_lists:
        to_lists_real.append(ls[ls.index('"') + 1:ls.rfind('"'):])
    with open(output_file_path, 'tw', encoding='utf8') as output_file:
        for source_line in source_lists:
            if source_line not in to_lists_real:
                output_file.write(source_line + "\n")

```