---
layout: post
title:  用ruby跑命令行安装软件时报错：SSL_connect 相关
date:   2016-04-14 09:00:13
categories: Tools
---
用ruby跑命令行安装软件时报错：SSL_connect 相关
<!--more-->
## 问题：折腾Octopress遇到插件无法安装

```
Gem::RemoteFetcher::FetchError: Errno::ECONNRESET: An existing connection was forcibly closed by the remote host. - SSL_connect (https://rubygems.org/gems/rake-10.5.0.gem)
```

## 原因：

链接被Greate Wall屏蔽了

## 解决办法：

* 1.修改Gemfile文件，把`source "https://rubygems.org"`改为：`source "http://rubygems.org"`

* 2.修改`https://rubygems.org`地址为国内镜像：`https://ruby-china.org`
