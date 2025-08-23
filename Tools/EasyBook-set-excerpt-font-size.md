---
layout: post
title:  EasyBook设置首页展示
date:   2016-03-15 09:00:13
categories: Tools
---
简单试了一下以EasyBook为主题的Jekyll博客首页页面的定制。
<!--more-->
## 修改字体大小

在`css/main.scss` 文件中修改全局的字体格式。

## 修改首页展示的字体大小，间距

在`_sass/_home.scss` 文件中，找到`post-excerpt` : 摘抄，修改这里的样式就会改变首页展示的字体。

字体大小 ： `font-size: $small-font-size;`

行距 ：`line-height: 1.75;`

## 中文文件名支持

[jekyll 本地调试文件名中文错误解决](http://chiyiw.com/2016/03/20/jekyll-%E6%9C%AC%E5%9C%B0%E8%B0%83%E8%AF%95%E6%96%87%E4%BB%B6%E5%90%8D%E4%B8%AD%E6%96%87%E9%94%99%E8%AF%AF%E8%A7%A3%E5%86%B3.html)
