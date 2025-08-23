---
title: AsyncTask的一些疑问
date: 2017-01-22 21:26:02
categories: Android
tags: Android
---
## 带着问题看源码
- 为什么只能在UI线程创建？
- 为什么只能在主线程中调用 `AsyncTask#execute()` ?
- 为什么一个AsyncTask实例只能执行一次？

<!-- more -->

## 使用方式
新建类继承AsyncTask，实现其doInBackground方法

```java
protected void onPreExecute()
protected String doInBackground(String... params)
protected void onProgressUpdate(Integer... values)
protected void onCancelled()
protected void onCancelled(String s)
protected void onPostExecute(String s)
```

或者直接new

```java
AsyncTask<String, Integer, String> asyncTask
                = new AsyncTask<String, Integer, String>() {
    @Override
    protected String doInBackground(String... params) {
        return null;
    }
};
asyncTask.execute("hii");
```

在 `doInBackground(String... params)` 中要更新UI可以调用 `publishProgress(Progress... values)` , `publishProgress()` 方法本身执行在异步线程，但会调用 Handler 发 `MESSAGE_POST_PROGRESS`事件抛到主线程，让 `onProgressUpdate(Integer... values)` 处理，不要手动调用 `onProgressUpdate(Integer... values)`。

<!--more-->

## 为什么只能在UI线程创建？

因为Android老的版本上用于线程间通信的 InternalHandler 创建时没有为其指定Looper，所以它会默认使用当前线程的Looper，如果当前线程没有事先调用过 `Looper.prepare()` ，就会报 `RuntimeException("Can't create handler inside thread that has not called Looper.prepare()")` 异常，即使调用过 `Looper.prepare()` 由于不是主线程，也不能去修改UI。至少在API 16上是这样，后来的版本里面这条被修改了，AsyncTask 在实例化 InternalHandler 是为其指定主线程。

```java
public InternalHandler() {
    super(Looper.getMainLooper());
}
```

## 为什么只能在主线程中调用 AsyncTask#execute() ?

先看执行代码：

```java
@MainThread
public final AsyncTask<Params, Progress, Result> execute(Params... params) {
    return executeOnExecutor(sDefaultExecutor, params);
}

@MainThread
public final AsyncTask<Params, Progress, Result> executeOnExecutor(Executor exec,
        Params... params) {
    if (mStatus != Status.PENDING) {
        switch (mStatus) {
            case RUNNING:
                throw new IllegalStateException("Cannot execute task:"
                        + " the task is already running.");
            case FINISHED:
                throw new IllegalStateException("Cannot execute task:"
                        + " the task has already been executed "
                        + "(a task can be executed only once)");
        }
    }

    mStatus = Status.RUNNING;

    onPreExecute();

    mWorker.mParams = params;
    exec.execute(mFuture);

    return this;
}
```

并没有为 `onPreExecute()` 方法的执行特别指定线程，所以 `onPreExecute()` 是执行在当前线程，如果要在 `onPreExecute()` 中修改UI的话，`AsyncTask#execute()` 就要在UI线程中执行。

## 为什么一个AsyncTask实例只能执行一次？

在并发条件下多次执行execute(),会让线程内的数据不安全，并没有加锁机制，而是限制一个Task只能被执行一次。

## 其他

仿 AsyncTask 做的一个单线程执行工具（从《Android开发进阶》这本书上看到的）

[DbCommand.java](https://github.com/AmoryPepelu/AndroidDemo/blob/master/androiddevpro/src/main/java/github/amorypepelu/androiddevpro/chapter_5_3/DbCommand.java)

可以改单线程为多个线程：

```java
private static int coreThreadNum = Runtime.getRuntime().availableProcessors();
private final static ExecutorService executor = new ThreadPoolExecutor(
         coreThreadNum, coreThreadNum, 0L, TimeUnit.MILLISECONDS, new LinkedBlockingQueue<Runnable>());
```