---
title: org-json的使用
date: 2016-11-09 22:17:35
categories: Android
tags: JSON
---
简单，减少jar包的导入。
<!--more-->
## 解析Json Object

```java
public void parse_json_obj(View view) {
    try {
        JSONObject jsonObject = new JSONObject(JS.JSObj);
        String s = jsonObject.optString("topic_c_ver");
        Log.d(TAG, "json obj=" + s);
    } catch (JSONException e) {
        e.printStackTrace();
    }
}
```

`optString(String)`是尝试解析。

## 解析Json Array

```java
try {
    JSONArray jsonArray = new JSONArray(JS.jsArray);
    ArrayList<JsonArrayItem> list = new ArrayList<>();
    for (int i = 0; i < jsonArray.length(); i++) {
        JSONObject jsonObject = (JSONObject) jsonArray.get(i);
        int id = jsonObject.getInt("ID");
        String question = jsonObject.getString("Question");
        String answer = jsonObject.getString("Answer");
        JsonArrayItem item = new JsonArrayItem(id, question, answer);
        list.add(item);
    }
    Log.d(TAG, "array size=" + list.size());
} catch (JSONException e) {
    e.printStackTrace();
}
```

## String to Json Object

`JSONObject#put(String name, Object value)`

```java
JSONStringer jsonStringer = new JSONStringer();
try {
    String js = jsonStringer.object().key("hello").value("bitch").endObject().toString();
    Log.d(TAG, "json obj String=" + js);
} catch (JSONException e) {
    e.printStackTrace();
}
```

或者

```java
JSONObject jsonObject = new JSONObject();
try {
    jsonObject.put("hello", "bitch");
    Log.d(TAG, "json obj String=" + jsonObject.toString());
} catch (JSONException e) {
    e.printStackTrace();
}
```

## String to Json Array

使用`JSONArray#put(Object)`。

```java
JSONArray jsonArray = new JSONArray();
jsonArray.put("bli").put("hgh").put(jsonObject);
Log.d(TAG, jsonArray.toString());
```
