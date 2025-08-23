---
layout: post
title:  Hexo的使用
date:   2015-04-02 09:00:13
categories: hexo
---
总结一下hexo的使用技巧
<!-- more -->

## 配置升级
```
title: BlackNeko
description: 我的征途是星辰大海
author: BlackNeko
language: zh-CN
```


## 首页展示折叠

在需要折叠的地方添加 `<!--more-->`

## 指令
[指令集](https://hexo.io/zh-cn/docs/commands.html)

* hexo g = hexo generate  // 生成

* hexo d = hexo deploy    // 部署

* hexo s = hexo server    // 运行服务器

* hexo new post "article title"    //新建文章

## 头像设置

参考：[设置侧边栏头像](https://github.com/iissnan/hexo-theme-next/wiki/%E8%AE%BE%E7%BD%AE%E4%BE%A7%E8%BE%B9%E6%A0%8F%E5%A4%B4%E5%83%8F "Title")

## 文章中插入图片

使用markdown写文章，插入图片的格式为`![图片名称](链接地址)`，这里要说的是链接地址怎么写。对于hexo，有两种方式：

1. 使用本地路径：在`hexo/source`目录下新建一个`img`文件夹，将图片放入该文件夹下，插入图片时链接即为`/img/图片名称`。

2. 使用*微博图床*，地址[http://weibotuchuang.sinaapp.com/](http://weibotuchuang.sinaapp.com/)，将图片拖入区域中，会生成图片的URL，这就是链接地址

## 分页设置

在配置`站点配置文件`中添加:

```
index_generator:
  per_page: 5

archive_generator:
  per_page: 20
  yearly: true
  monthly: true

tag_generator:
  per_page: 10
```

分别是主页、归档和标签的页数。如果部署失败就先执行 `$ npm i --save` ，参考：[首页分页和归档分页不同是如何做到的](https://github.com/iissnan/hexo-theme-next/issues/30 "Title")

## 新建自定义标签

在项目目录执行 `hexo new page ${PAGE_NAME}` ，在主题配置文件中增加以PAGE_NAME为名的menu，会在`${blog_path}\source\`文件夹下面生成对应`PAGE_NAME`名的文件夹，文件中有个`index.md`文件就是了，只要在写作的md文件头部加上`PAGE_NAME`就可以了，参考tag，categories...的创建，汉化：在 `languages/zh-Hans.yml` 文件的menu下面新增PAGE_NAME并汉化。

参考：[创建分类页面](https://github.com/iissnan/hexo-theme-next/wiki/%E5%88%9B%E5%BB%BA%E5%88%86%E7%B1%BB%E9%A1%B5%E9%9D%A2)

## 字体大小更改

在`${Blog}\themes\next\source\css\_variables\custom.styl`文件里面添加：

```css
$font-size-base           = 16px
$code-font-size           = 14px
```

参考：[next-常见问题](http://theme-next.iissnan.com/faqs.html)

修改代码字体大小后，在火狐浏览器上变得惨不忍睹（缩成一团），修改`${Blog}\themes\next\source\css\_variables\base.styl`文件下的

```css
$line-height-code-block = 1.5
```

原值是`1.6`。好多问题在next的issue下面都有讨论的。~~有可能是code字体每增大1，`line-height-code-block`的值减小0.1，未验证~~。

## 生成默认带有categories的模板

使用`hexo new ${post_title}`生成模板时通常只有`title`,`date`,`tags`三个标签，想要加标签的话就在`${blog_path}\scaffolds\post.md`文件中添加一个标签就可以了。

## 菜单栏排序

在`主题配置文件`中找到`menu`配置块，调整顺序即可。

## 侧边栏默认显示与否配置

在`主题配置文件`中，找到`sidebar`块，配置`display`。

## 网站图标设置

在`主题配置文件`中配置`favicon`，配置为`favicon: /images/favicon.ico`，把图标文件`favicon.ico`放到`${blog}\images\`文件夹下即可。

## 头像设置

在`主题配置文件`中配置`avatar`为`avatar: /images/avatar3.jpg`或者一个链接的地址，然后在`主题`目录下的images文件夹下面放置头像jpg文件。

## 文章中添加图片

在插入图片的位置写`/images/${image_name}`，把图片放在`${blog_path}\images\`文件夹下面。

## 设置文章在屏幕上显示的宽度

在`${blog_path}\themes\next\source\css\_variables\custom.styl`中添加

```
// 修改成你期望的宽度
$content-desktop = 800px

// 当视窗超过 1600px 后的宽度
$content-desktop-large = 900px
```

## 注意

* 在用`hexo new <post_name>`新建post时，标题有空格的要加`""`。

参考：

[NexT文档](http://theme-next.iissnan.com/getting-started.html)

[NexT项目地址](https://github.com/iissnan/hexo-theme-next)

[Hexo中文文档](https://hexo.io/zh-cn/docs/index.html)

[如何在一天之内搭建以你自己名字为域名且具备cool属性的个人博客](http://www.jianshu.com/p/99665608d295)
