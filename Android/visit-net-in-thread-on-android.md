---
layout: post
title:  在子线程中同步访问网络
date:   2016-02-16 09:00:00
categories: Android
---
一个偶然的机会需要在子线程中多次访问网络，因此考虑同步访问的方式。

在子线程中访问网络，支持GET,POST模式。不可以在其中修改UI，如果需要请使用handler-message。
<!--more-->
## 新开一个线程

```java
private Thread failOrderThread;

private void createNewThread() {
	failOrderThread = new Thread(new Runnable() {
		@Override
		public void run() {
			while (!failOrderThread.isInterrupted()) {
				Log.d(TAG + "thread", "thread working !!");
				// 线程休眠1分钟
				try {
					Thread.sleep(60000);
				} catch (InterruptedException e) {
					// 终止线程
					Thread.currentThread().interrupt();
					Log.d(TAG, "thread interrupted !!");
					e.printStackTrace();
				}
				//访问网络
				syncNetRequest(String url, String type, HashMap<String, String> params);
			}
		}
	});
}
```

在程序运行期间，此线程一直跑：`while (!thread.isInterrupted())` ,当需要中止线程时，调用：`thread.interrupt()` ,在线程执行`Thread.sleep(3 * 1000)` 时，会进入到`InterruptedException`代码块，执行`Thread.currentThread().interrupt()` ，从而中断线程。

开启线程时使用：

```java
if (thread != null && !thread.isAlive()) {
	Log.d(TAG, "start thread");
	thread.start();
}
```

防止同一线程重复开启。

## 同步访问网络

```java
private void syncNetRequest(String url, String type, HashMap<String, String> params) {
	Log.d(TAG, "testNetRequest activity is null:" + (this == null));
	StringBuffer sb = new StringBuffer();
	HttpURLConnection conn = null;
	OutputStreamWriter out = null;
	BufferedWriter bw = null;
	InputStreamReader isr = null;
	BufferedReader br = null;
	try {
		URL u = new URL(url);
		conn = (HttpURLConnection) u.openConnection();
		conn.setRequestMethod(type);
		conn.setConnectTimeout(connectTimeout);
		conn.setReadTimeout(readTimeout);
		if (POST.equals(type)) {
			conn.setDoOutput(true);
		}
		conn.setDoInput(true);
		conn.connect();
		if (POST.equals(type)) {
			String data = praseMap(params);
			Log.d(TAG, "data:" + data);
			// 传送数据
			if (data != null && !"".equals(data)) {
				out = new OutputStreamWriter(conn.getOutputStream(), "utf-8");
				bw = new BufferedWriter(out);
				bw.write(data);
				bw.flush();
			}
		}
		// 接收数据
		if (conn.getResponseCode() == 200) {
			isr = new InputStreamReader(conn.getInputStream(), "utf-8");
			br = new BufferedReader(isr);
			String line;
			while ((line = br.readLine()) != null) {
				sb.append(line).append(System.getProperty("line.separator"));
			}
			Log.d(TAG, "testNetRequest:" + sb.toString());
		//	Log.d(TAG, "system separator:" + System.getProperty("line.separator"));
		}
	} catch (Exception e) {
		e.printStackTrace();
	} finally {
		Log.d(TAG, "finally");
		try {
			if (bw != null) {
				bw.close();
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		try {
			if (out != null) {
				out.close();
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		try {
			if (br != null) {
				br.close();
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		try {
			if (isr != null) {
				isr.close();
			}

		} catch (Exception e) {
			e.printStackTrace();
		}
		try {
			if (conn != null) {
				conn.disconnect();
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
}
```

## 解析Map参数

```java
private String praseMap(HashMap<String, String> map) {
	StringBuffer sb = new StringBuffer();
	if (map != null && !map.isEmpty()) {
		try {
			boolean f = true;
			String v;
			for (String k : map.keySet()) {
				if (k != null && !"".equals(k)) {
					v = map.get(k);
					if (v != null) {
						v = v.trim();
					}
					if (!f)
						sb.append("&");
					v = URLEncoder.encode(v, "utf-8");
					sb.append(k).append("=").append(v);
					f = false;
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	return sb.toString().trim();
}
```

## 中止线程

在程序退出，Activity销毁时，为了防止空指针异常，需要中止线程：

```java
@Override
protected void onDestroy() {
	Log.d(TAG, "on activity destory");
	thread.interrupt();
	super.onDestroy();
}
```
