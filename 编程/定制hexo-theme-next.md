---
title: 定制hexo-theme-next
date: 2025-08-19 23:25:27
tags: hexo-next
categories: 编程
---

### 过滤指定文章

1. 在文章的 Front-matter 中添加标记
打开无标题文章的 Markdown 文件，添加 `hide: true：`

```
---
title: ""  # 标题为空
date: 2025-08-19
hide: true  # 手动标记隐藏
---
```

2. 定位模板文件
打开 Next 主题的首页模板文件：`themes/next/layout/index.njk`

3. 添加条件判断
在文章循环部分（通常以 `{% for post in page.posts %}` 开头）插入标题检查逻辑：

```
{% block content %}

  {%- for post in page.posts.toArray() %}
     <!-- 检查标题非空 -->
     {% if not post.hide %} 
        {{ partial('_macro/post.njk', {post: post, is_index: true}) }}
     {% endif %}
  {%- endfor %}

  {%- include '_partials/pagination.njk' -%}

{% endblock %}
```

4. 重启 Hexo 服务
清理缓存并重新生成页面：
```
hexo clean && hexo g && hexo s
```

### 过滤标题为空的文章

修改上述第三步

```
{% block content %}

  {%- for post in page.posts.toArray() %}
     <!-- 检查标题非空 -->
     {% if post.title and post.title.trim() !== '' and not post.hide %} 
        {{ partial('_macro/post.njk', {post: post, is_index: true}) }}
     {% endif %}
  {%- endfor %}

  {%- include '_partials/pagination.njk' -%}

{% endblock %}
```
