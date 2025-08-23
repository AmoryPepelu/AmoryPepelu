---
title: 线程池
date: 2017-01-01 17:07:17
categories: Java
tags: Thread
---
Java线程池学习笔记。

<!-- more -->

## 创建线程池

```java
ThreadPoolExecutor threadPoolExecutor =
                new ThreadPoolExecutor(2, 4, 1L,
                        TimeUnit.SECONDS, new LinkedBlockingDeque<>(3));
```

构造函数:

```java
public ThreadPoolExecutor(int corePoolSize,
                        int maximumPoolSize,
                        long keepAliveTime,
                        TimeUnit unit,
                        BlockingQueue<Runnable> workQueue)
```

参数分析：

* corePoolSize : 核心线程数
* maximumPoolSize : 最大线程数
* keepAliveTime : 非核心线程闲置时的超时时长，如果设置 `ThreadPoolExecutor#allowCoreThreadTimeOut(true)`，则核心线程也会在执行完任务后，在等待keepAliveTime时间后终止
* unit : TimeUnit枚举
* workQueue : 线程池中的任务队列

任务队列实现类：

* ArrayBlockingQueue : 基于数组结构，FIFO（先进先出）
* LinkedBlockingQueue : 链表，FIFO
* SynchronousQueue : 不存储元素，每个插入操作必须等到另一个线程调用移除操作，否则一直处于阻塞状态。Executors.newCachedThreadPool()使用。
* PriorityBlockingQueue : 有优先级，无阻塞。

此构造函数调用了重载的构造函数，使用了默认的 ThreadFactory 和 RejectedExecutionHandler，最终构造函数：

```java
public ThreadPoolExecutor(int corePoolSize,
                        int maximumPoolSize,
                        long keepAliveTime,
                        TimeUnit unit,
                        BlockingQueue<Runnable> workQueue,
                        ThreadFactory threadFactory,
                        RejectedExecutionHandler handler) 
```

* ThreadFactory : 创造线程工厂
* RejectedExecutionHandler : 饱和策略，线程池满后，新任务添加后的处理

饱和策略：他们都实现RejectedExecutionHandler接口

* AbortPolicy : 默认实现，直接抛出异常 `RejectedExecutionException`
* CallerRunsPolicy : 只用调用者所在的线程来执行任务
* DiscardOldestPolicy : 丢弃队列里最近的一个任务，并执行当前任务
* DiscardPolicy : 不处理，丢弃

创建饱和策略实现类：

```java
new ThreadPoolExecutor.AbortPolicy();
new ThreadPoolExecutor.CallerRunsPolicy();
new ThreadPoolExecutor.DiscardOldestPolicy();
new ThreadPoolExecutor.DiscardPolicy();
```

例如：

```java
ThreadPoolExecutor threadPoolExecutor = new ThreadPoolExecutor(
                2, 4, 1, TimeUnit.SECONDS, new LinkedBlockingDeque<>(3),
                new ThreadFactory() {
                    @Override
                    public Thread newThread(Runnable r) {
                        //create thread 创造线程
                        return new Thread(r, "thread#name");
                    }
                }, new RejectedExecutionHandler() {
                    @Override
                    public void rejectedExecution(Runnable r, ThreadPoolExecutor executor) {
                        //do something
                        //线程池满后，新任务添加后的处理
                    }
        });
```

最多任务数 = 核心线程数 + 非核心线程数 + 任务队列长度

非核心线程数 = 最大线程数 - 核心线程数

即：

最多任务数 = 最大线程数 + 任务队列长度

## 线程池中的线程开启顺序

核心线程 -> 任务队列 -> 非核心线程 -> 饱和策略

```java
public void execute(Runnable command) {
    if (command == null)
        throw new NullPointerException();
    int c = ctl.get();
    //线程数小于核心线程数，创建线程并执行
    if (workerCountOf(c) < corePoolSize) {
        if (addWorker(command, true))
            return;
        c = ctl.get();
    }
    //加入任务队列
    if (isRunning(c) && workQueue.offer(command)) {
        int recheck = ctl.get();
        if (! isRunning(recheck) && remove(command))
            reject(command);
        else if (workerCountOf(recheck) == 0)
            addWorker(null, false);
    }
    //开启非核心线程
    else if (!addWorker(command, false)){
        //开启失败，饱和策略
        reject(command);
    }
}
```

## 线程池分类

* FixedThreadPool : 数量固定，只有核心线程，或者说是全是核心线程，没有超时机制，任务队列没有限制

```java
Executors.newFixedThreadPool( int nThreads);

public static ExecutorService newFixedThreadPool(int nThreads) {
    return new ThreadPoolExecutor(nThreads, nThreads,
                                    0L, TimeUnit.MILLISECONDS,
                                    new LinkedBlockingQueue<Runnable>());
}
```

* CachedThreadPool : 无核心线程，非核心线程可看做无限大，每个线程无任务60s闲置会被回收，任务队列没有限制，适合大量耗时较少的任务。

```java
Executors.newCachedThreadPool();

public static ExecutorService newCachedThreadPool() {
    return new ThreadPoolExecutor(0, Integer.MAX_VALUE,
                                    60L, TimeUnit.SECONDS,
                                    new SynchronousQueue<Runnable>());
}
```

* ScheduledThreadPool : 核心线程数固定，非核心线程可看做无限大，任务队列没有限制，适合执行定时任务何具有固定周期的重复任务。

```java
Executors.newScheduledThreadPool( int corePoolSize);

public static ScheduledExecutorService newScheduledThreadPool(int corePoolSize) {
    return new ScheduledThreadPoolExecutor(corePoolSize);
}

public ScheduledThreadPoolExecutor(int corePoolSize) {
    super(corePoolSize, Integer.MAX_VALUE, 0, NANOSECONDS,
            new DelayedWorkQueue());
}
```

* SingleThreadExecutor : 保持所有任务都在同一个线程中执行。

```java
Executors.newSingleThreadExecutor();

public static ExecutorService newSingleThreadExecutor() {
    return new FinalizableDelegatedExecutorService
        (new ThreadPoolExecutor(1, 1,
                                0L, TimeUnit.MILLISECONDS,
                                new LinkedBlockingQueue<Runnable>()));
}
```

## 提交任务

无返回结果：

```java
threadPoolExecutor.execute(new Runnable() {
    @Override
    public void run() {
        System.out.println("running " + Thread.currentThread().getName());
    }
});
```

有返回结果：

```java
Future<String> future = threadPoolExecutor.submit(new Callable<String>() {
    @Override
    public String call() throws Exception {
        String result = "hello bitch!";
        Thread.sleep(3000);
        return result;
    }
});

try {
    String result = future.get();
    System.out.println(result);
} catch (InterruptedException e) {
    e.printStackTrace();
} catch (ExecutionException e) {
    e.printStackTrace();
}
```

Future#get() 是阻塞的，在结果返回前会一直等待。

## 关闭线程池

```java
threadPoolExecutor.shutdown();
threadPoolExecutor.shutdownNow();
threadPoolExecutor.isShutdown();
threadPoolExecutor.isTerminated();
threadPoolExecutor.isTerminating();
```

shutdown，shutdownNow：遍历工作线程，逐个调用线程的interrupt。

shutdownNow首先将线程池状态设置为stop，尝试停止正在执行的或是暂停任务的线程，返回等待执行任务的列表。

shutdown只是把线程状态设置为SHUTDOWN，中断没有正在执行的线程。

调用shutdown，shutdownNow任意一个方法，isShutdown都会返回true。所有任务都关闭后，isTerminated返回true。

## 线程池配置

```java
//获取当前设备CPU个数
Runtime.getRuntime().availableProcessors();
```

* CPU密集型配置尽可能小的线程，N(cpu) + 1
* IO 密集型配置尽可能多的线程，N(cpu) * 2
* 使用有界队列，防止线程开太多

## 线程池的监控

```java
//线程池中需要执行的任务数量，总任务数量
threadPoolExecutor.getTaskCount();

//已完成
threadPoolExecutor.getCompletedTaskCount();

//曾经创建过的最大线程数量，可用来判断线程池是否满过
threadPoolExecutor.getLargestPoolSize();

//线程池中的线程数量
threadPoolExecutor.getPoolSize();

//获取活动的线程数
threadPoolExecutor.getActiveCount();
```