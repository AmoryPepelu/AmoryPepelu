---
title: 在Hexo-Next主题中去除文章目录的自动编号
date: 2025-08-22 08:38:52
tags: next
categories: hexo
---

要在Hexo-Next主题中去除文章目录（Table of Contents, TOC）的自动编号，可通过以下三种方法实现，根据需求选择全局或单篇配置。

<!-- more -->

### 🔧 一、修改主题配置文件（推荐全局生效）

1. 定位配置文件
打开Next主题的配置文件：`themes/next/_config.yml`。

2. 修改TOC编号参数
搜索关键词 toc，找到以下配置项，将 number 的值改为 false：
```
toc:
  number: false  # 关闭目录自动编号
  wrap: false    # 可选，防止目录换行
```

3. 保存并生效
修改后运行命令清理缓存并重新生成：
```
hexo clean && hexo g && hexo s  # 本地预览
hexo d                          # 部署到服务器
```

### 🛠️ 二、修改模板文件（兼容旧版主题）
若上述配置无效（如旧版Next主题），可直接修改模板文件：

打开文件 `themes/next/layout/_macro/post.swig`。
搜索 `toc(content)`，修改为：
```
{{ toc(content, { list_number: false }) }}
```

保存后重新生成博客。

### 📄 三、单篇文章禁用编号（Front-matter控制）
在文章的Markdown文件头部添加 `toc_number: false`，仅对当前文章生效：
```
---
title: 示例文章
date: 2025-08-22
toc: true          # 启用目录
toc_number: false  # 禁用当前文章的目录编号
---
```

### ✅ 四、验证效果

本地预览：执行 `hexo s` 后访问  http://localhost:4000。
部署后：确认远程页面目录编号已消失。

💡 提示：若需保留部分文章的编号，推荐使用第三种方法；全局修改则首选第一种。修改配置文件后若未生效，尝试清理缓存（hexo clean）。
