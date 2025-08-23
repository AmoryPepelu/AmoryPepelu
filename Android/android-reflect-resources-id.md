---
layout: post
title: Android反射取资源id
date: 2016-09-01 22:18:49
categories: Android
---
Android反射取资源id，虽然用包名加R取资源id是最快的，但有时是无法这么做的，比如一些包名经常会改变的APP。
<!--more-->
```java
public class ReflectResources {

    /**
     * 资源反射
     *
     * @param context
     * @param name
     * @param type
     * @return
     */
    private static int getResourceId(Context context, String name, String type) {
        int id = 0;
        id = context.getResources().getIdentifier(name, type, context.getPackageName());
        return id;
    }

    /**
     * 对于context.getResources().getIdentifier
     *
     * @param context
     * @param name
     * @param type
     * @return
     */
    private static Object getResourceIdNew(Context context, String name, String type) {
        String className = context.getPackageName() + ".R";
//		Log.i("BJMEngine", "getResourceIdNew " + className);
        try {
            Class<?> cls = Class.forName(className);
            for (Class<?> childClass : cls.getClasses()) {
                String simple = childClass.getSimpleName();
                if (simple.equals(type)) {
                    for (Field field : childClass.getFields()) {
                        String fieldName = field.getName();
                        if (fieldName.equals(name)) {
//							System.out.println(fieldName);
                            return field.get(null);
                        }
                    }
                }
            }
        } catch (Exception e) {
//			e.printStackTrace();
        }
        return null;
    }

    public static int getViewId(Context context, String name) {
        return getResourceId(context, name, "id");
    }

    public static int getLayoutId(Context context, String name) {
        return getResourceId(context, name, "layout");
    }

    public static int getStringId(Context context, String name) {
        return getResourceId(context, name, "string");
    }

    public static int getDrawableId(Context context, String name) {
        return getResourceId(context, name, "drawable");
    }

    public static int getStyleId(Context context, String name) {
        return getResourceId(context, name, "style");
    }

    public static int getDimenId(Context context, String name) {
        return getResourceId(context, name, "dimen");
    }

    public static int getArrayId(Context context, String name) {
        return getResourceId(context, name, "array");
    }

    public static int getColorId(Context context, String name) {
        return getResourceId(context, name, "color");
    }

    public static int getAnimId(Context context, String name) {
        return getResourceId(context, name, "anim");
    }

    /**
     * context.getResources().getIdentifier无法获取到styleable的数
     *
     * @param context
     * @param name
     * @return
     */
    public static int getStyleable(Context context, String name) {
        return ((Integer) getResourceIdNew(context, name, "styleable")).intValue();
    }

    /**
     * 获取styleable的ID号数
     *
     * @param context
     * @param name
     * @return
     */
    public static int[] getStyleableArray(Context context, String name) {
        return (int[]) getResourceIdNew(context, name, "styleable");
    }

}
```

对于普通的资源如id,layout,color,anim,array,dimen,drawable,string等，可以直接取值，但另一些复杂些的资源就需要用反射来搞了。
