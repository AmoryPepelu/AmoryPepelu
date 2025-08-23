---
title: 为System.exit添加回调-监听用户杀进程
date: 2017-07-18 07:43:04
categories: Android
tags: Android
---
在app中调用 `System.exit(0)` 时，当前activity的 `onDestroy()` 方法没有被调用，现在为 `System.exit(0)` 方法添加一个回调。

未能上线，因为无法解决用户手动杀进程监听，就当是做源码分析了吧。

<!--more-->

## 为System.exit添加回调

System.exit(int):


```java
 public static void exit(int status) {
    Runtime.getRuntime().exit(status);
}
```

Runtime#exit(int)

```java
public void exit(int status) {
    // Make sure we don't try this several times
    synchronized(this) {
        if (!shuttingDown) {
            shuttingDown = true;

            Thread[] hooks;
            synchronized (shutdownHooks) {
                // create a copy of the hooks
                hooks = new Thread[shutdownHooks.size()];
                shutdownHooks.toArray(hooks);
            }

            // Start all shutdown hooks concurrently
            for (Thread hook : hooks) {
                hook.start();
            }

            // Wait for all shutdown hooks to finish
            for (Thread hook : hooks) {
                try {
                    hook.join();
                } catch (InterruptedException ex) {
                    // Ignore, since we are at VM shutdown.
                }
            }

            // Ensure finalization on exit, if requested
            if (finalizeOnExit) {
                runFinalization();
            }

            // Get out of here finally...
            nativeExit(status);
        }
    }
}
```

看到在调用 `nativeExit(status)` 之前，还会执行一组hook的线程，考虑在hook中监听 exit(int) 回调。

添加 hook 回调：

```java
Thread shutDownHook = null;
shutDownHook = new ShutDownHooksThread();

//要在 System.exit(0); 之前调用
Runtime.getRuntime().addShutdownHook(shutDownHook);

class ShutDownHooksThread extends Thread {

    /**
    * 同步执行，不能执行UI操作，因为VM状态在  System.exit(0); 时已被修改 : shuttingDown
    */
    @Override
    public void run() {
        super.run();
        //java.lang.IllegalStateException: VM already shutting down
        // Runtime.getRuntime().removeShutdownHook(ShutDownHooksThread.this);
        Log.i("pepelu", "run: ShutdownHook: start");

//            exitAndFinish.post(new Runnable() {
//                @Override
//                public void run() {
//                    exitAndFinish.setText("vm shut down");
//                }
//            });

        try {
            Thread.sleep(5000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }

        Log.i("pepelu", "run: ShutdownHook end");
    }
}
```

不能在 ShutDownHooksThread 中修改UI，因为VM状态在  System.exit(0); 时已被修改为 shuttingDown，并且此线程也并不是UI线程。但可以通过 View#post的形式上抛事件，然而并没有效果，View并不会发生改变。在ShutDownHooksThread中执行耗时操作，此时View会卡住，点击界面没有反应，长时间会报ANR。

shutDownHook 线程会被添加到Runtime内部一个线程列表中 :

```java
/**
* Holds the list of threads to run when the VM terminates
*/
private List<Thread> shutdownHooks = new ArrayList<Thread>();
```

不可以在 ShutDownHooksThread#run() 调用 Runtime.getRuntime().removeShutdownHook(ShutDownHooksThread.this); 因为此时VM已经 shut down，会报错：java.lang.IllegalStateException: VM already shutting down 。

当调用 Activity#finish() 后，app 进程要过一段时间才会被杀死，这时再进app，之前添加的 ShutDownHooksThread 仍然保存在Runtime的线程组中，如果 ShutDownHooksThread 保有外部对象的引用，就会发生内存泄露。当下次再调用 Runtime.getRuntime().addShutdownHook(shutDownHook) 添加线程，然后调用 System.exit(0) 触发回调，就会发生两次回调。

因此要在调用 addShutdownHook() 之前判断下Runtime的线程列表中是否已经包含此回调。

```java
 boolean isHookExit(Thread thread) {
     boolean isContainsHooks = false;
    try {
        Field field = Runtime.class.getDeclaredField("shutdownHooks");
        field.setAccessible(true);
        ArrayList<Thread> arrayList = (ArrayList<Thread>) field.get(Runtime.getRuntime());
        isContainsHooks = arrayList.contains(thread);
        Log.i("pepelu", "isHookExit: " + isContainsHooks);
    } catch (NoSuchFieldException e) {
        e.printStackTrace();
    } catch (IllegalAccessException e) {
        e.printStackTrace();
    } catch (Exception e) {
        e.printStackTrace();
    }
    return isContainsHooks;
}
```

先调用 Activity#finish() ，再调用 System.exit(0) ，app界面先退出，然后回调 ShutDownHooksThread#run()

然而即使给 System.exit(0) 添加了回调，当用户后台杀进程app时，ShutDownHooksThread的run() 方法也并没有被调用 ┑(￣Д ￣)┍

## 监听用户杀进程

```java
public class MyService extends Service {

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }
    
    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        Log.i(MainActivity.TAG, "onStartCommand: pid=" + android.os.Process.myPid());
        return START_STICKY;
    }
    
    @Override
    public void onTaskRemoved(Intent rootIntent) {
        super.onTaskRemoved(rootIntent);
        Log.i(MainActivity.TAG, "onTaskRemoved: ");
    }
    
    @Override
    public void onDestroy() {
        Log.i(MainActivity.TAG, "MyService onDestroy");
        super.onDestroy();
    
    }
}
```

```xml

 <service
        android:name=".MyService"
        android:stopWithTask="false" />

```

用menu杀进程时 onTaskRemoved 会走，在应用管理里面停止进程时，onDestroy会走

onTaskRemoved 在之前调用

```
07-07 17:10:57.233 11089-11831/? I/ActivityManager: Force stopping com.pxworks.backdemo appid=10536 user=0: from pid 11423
07-07 17:10:57.234 11089-11831/? I/ActivityManager: Killing 28664:com.pxworks.backdemo/u0a536 (adj 0): stop com.pxworks.backdemo: from pid 11423
```