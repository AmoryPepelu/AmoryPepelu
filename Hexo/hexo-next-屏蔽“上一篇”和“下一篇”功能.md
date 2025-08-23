---
title: 定制hexo-next:屏蔽“上一篇”和“下一篇”功能
date: 2025-08-22 23:49:39
tags: next
categories: hexo
disable_navigation: true
---
在next中搜索`theme.post_navigation`

修改if判断：
```
# 添加：and not post.disable_navigation
{%- if theme.post_navigation and (post.prev or post.next) 
    and not post.disable_navigation %}
```

在文章头部添加 `disable_navigation: true`:
```
---
title: hexo-next:屏蔽“上一篇”和“下一篇”功能
date: 2025-08-22 23:49:39
tags: next
categories: hexo
disable_navigation: true
---
```
