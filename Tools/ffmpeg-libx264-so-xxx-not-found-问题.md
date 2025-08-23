---
title: ffmpeg libx264.so.xxx not found 问题
date: 2019-02-27 09:53:02
tags: x264
categories: ffmpeg
---

ffmpeg 加载 x264 so 时出现该问题，需要修改 x264 的configure 文件

<!-- more -->

```
//change

SONAME=libx264.so.$API

//to

SONAME=libx264v$API.so
```

soname就是编译生成so库的名称的意思，这个名字不能是libx264.so，因为x264编译的时候会生成一个libx2641.so的中间文件，会冲突

