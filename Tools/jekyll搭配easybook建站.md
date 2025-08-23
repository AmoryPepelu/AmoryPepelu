---
layout: post
title: 使用jekyll结合EasyBook搭建个人github主页
date:   2016-03-16 09:00:13
categories: Tools
---
写这篇主要是总结一下我使用Jekyll时遇到的坑。
<!--more-->
## 安装环境

这个没什么好说的，主要就是参考这篇文章：[Run Jekyll on Windows](http://jekyll-windows.juthilo.com/1-ruby-and-devkit/) ，把Ruby环境搭建好。

然后根据官网的指示安装 Jekyll : [Quick-start guide](http://jekyllrb.com/docs/quickstart/ "Title") 。

过程中可能会遇到这样：

```
Error fetching https://ruby.taobao.org/:
        SSL_connect returned=1 errno=0 state=SSLv3 read server certificate B: ce
rtificate verify failed (https://rubygems-china.oss-cn-hangzhou.aliyuncs.com/spe
cs.4.8.gz)
```

或者是这样：

```
ERROR:  While executing gem ... (Gem::RemoteFetcher::FetchError)
    Errno::ECONNRESET: An existing connection was forcibly closed by the remote
host. - SSL_connect (https://api.rubygems.org/quick/Marshal.4.8/jekyll-3.1.2.gem
spec.rz)
```

还有这样：

```
ERROR: Could not find a valid gem 'jekyll' (>= 0), here is why:
https://github.com/juthilo/run-jekyll-on-windows/issues/34
```

的错误，解决办法是依次运行下面的指令：

```
$ gem sources --remove https://rubygems.org/
$ gem sources -a http://rubygems.org/
$ gem install jekyll
```

原因是`https://rubygems.org/`链接被Greate Wall屏蔽了，除了使用`http://rubygems.org/` 这个链接外也可以使用中国镜像:`https://ruby-china.org` (以前的淘宝镜像网站停止服务了，~~没有测试过~~)

## 使用EasyBook主题

参考：[快速上手指南](https://github.com/laobubu/jekyll-theme-EasyBook/wiki/%E5%BF%AB%E9%80%9F%E4%B8%8A%E6%89%8B%E6%8C%87%E5%8D%97 "Title") ，不要下载 Jekyll，直接clone EasyBook的项目就行了。

再使用jekyll调试的时候，报错：

```
Configuration file: E:/code/GitHub/Tonypepelu.github.io/_config.yml
  Dependency Error: Yikes! It looks like you don't have jekyll-paginate or one
f its dependencies installed. In order to use Jekyll as currently configured, y
u'll need to install this gem. The full error message from Ruby is: 'cannot loa
 such file -- jekyll-paginate' If you run into trouble, you can find helpful re
ources at http://jekyllrb.com/help/!
jekyll 3.1.2 | Error:  jekyll-paginate
```

原因：在 `_config.yml` 文件中使用到了一些东西并没有安装

```
gems:
 - jekyll-paginate
 - jekyll-gist
 - jemoji
```

解决办法：依次安装一下就行了

```
gem install jekyll-gist
gem install jemoji
gem install jekyll-paginate
```

## 添加评论

EasyBook里面已经集成了多说和[disqus](https://disqus.com/home/explore/ "Title") 的评论系统，这里采用 disqus的评论系统，到网站去注册一下，把js代码拷贝下来，参考：[使用Github Pages建独立博客](http://beiyuu.com/github-pages/ "Title") 取得js代码，拷贝到 `_includes/comments.html`文件中`disqus_thread` 标签下，覆盖原有内容。

## git提交

因为我已经在当前git命令中绑定过一个账号了，所以这个站点只能提交到别的账号中，我采用了fork新账号的git page项目然后提交pull request，让另一个账号merge的办法。参考：[Using pull requests](https://help.github.com/articles/using-pull-requests/ "Title") 。

## Jekyll调试

依次执行：

```
$ jekyll build
$ jekyll server
```

## 头像处理

这里采用 [小笠原](https://github.com/yaqinking "Title") 的做法，把图片托管到 [网站](http://imgur.com/) 上，然后在工程配置文件里添加： `avatar: "//i.imgur.com/DDbB8QL.jpg?"`  ，比较搞笑的是上传图片必须翻墙，不然传到一半进度条还能退回来。

## 写作

文章应该保存在 `_posts` 文件夹，文件命名格式：`YYYY-MM-DD-TITLE.TYPE` ，例如：

* `2011-12-31-new-years-eve-is-awesome.md`

* `2012-01-17-hello-world.md`

这个可以使用批处理来解决，详情见下篇文章。

## 发布

跳进一个坑里直到半夜才爬出来，[用Jekyll创建博客本地正常，上传到GitHub后不能显示文章列表？](https://segmentfault.com/q/1010000004584816/a-1020000004586702 "Title")  这个问题是因为：jekyll 3（github目前的jekyll版本）默认对于认定为"未来"的post，是不生成的，设置date后面的日期稍微提前一点，就可以了，比如设置为昨天。

## 文章摘要

文章第一段换行符之前的都是文章摘要。

## 有时标签的格式都正确但文件就是不能解析出来

检查文件的存储格式是否为utf-8无bom，否则不能成功展示。

## Python
Jekyll build时需要Python支持，但Python的版本不能太高，2.7正好。

## 定制显示字体大小

在`css/main.scss` 文件中修改全局的字体格式。

## 修改首页展示的字体大小，间距

在`_sass/_home.scss` 文件中，找到`post-excerpt` : 摘抄，修改这里的样式就会改变首页展示的字体。

字体大小 ： `font-size: $small-font-size;`

行距 ：`line-height: 1.75;`

设置代码缩进：在`_base.scss`中的`pre`块，添加`tab-size: 4;`

在`main.css`文件中`code`块设置代码行距

## 中文文件名支持

用中文作为文件名的时候，会出现文章找不到的情况，解决办法是：

修改`安装目录\Ruby22-x64\lib\ruby\2.2.0\webrick\httpservlet`下的`filehandler.rb`文件

找到下列两处，添加一句（`+`的一行为添加部分）

```
path = req.path_info.dup.force_encoding(Encoding.find("filesystem"))
+ path.force_encoding("UTF-8") # 加入编码
if trailing_pathsep?(req.path_info)
```

```
break if base == "/"
+ base.force_encoding("UTF-8") #加入編碼
break unless File.directory?(File.expand_path(res.filename + base))
```

在`_config.yml`中添加:`encoding: "utf-8"`，因为默认就是utf-8，所以这个要不要都行。

重启jekyll server

转自[jekyll 本地调试文件名中文错误解决](http://chiyiw.com/2016/03/20/jekyll-%E6%9C%AC%E5%9C%B0%E8%B0%83%E8%AF%95%E6%96%87%E4%BB%B6%E5%90%8D%E4%B8%AD%E6%96%87%E9%94%99%E8%AF%AF%E8%A7%A3%E5%86%B3.html)

## category排序

在`category.html`中修改：

```
{% assign category = categories | split:',' | sort | reverse %}
```

这个是逆序，添加了`reverse`。