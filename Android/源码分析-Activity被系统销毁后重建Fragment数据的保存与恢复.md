---
title: 源码分析:Activity被系统销毁后Fragment中保存的数据在哪里？
date: 2019-04-12 09:54:20
tags: 源码分析
categories: Android
---

分析Activity被系统销毁后，Fragment的重建与数据的保存和恢复逻辑。

<!-- more -->

## 遇到的问题

bugly上有个crash，是使用kotlin的 `lateinit var` 的属性没有被初始化造成的，相关代码如下：

```kotlin
class CpWxNumSucDialog : BaseDialogFragment() {
    private lateinit var wxNum: String

     public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        val binding = safeBind<LayoutCpWxSucBinding>(rootView!!)!!
        binding.tvWechat.text = wxNum // !! crash !!
    }

    fun setData(wxNum: String) {
        this.wxNum = wxNum
    }
}
```

分析崩溃日志发现Fragment依赖的Activity重新走了 `onCreate()` 创建流程，推测可能是由于用户按 home 键，在此Activity页面将应用退到后台，长期未唤起导致应用被系统回收，再次进入APP，系统恢复Activity状态导致。

## 修复问题

在 `setData()` 方法中，不使用直接赋值，而是使用 `arguments`

```
fun setData(wxNum: String) {
    arguments = Bundle().also {
        it.putString(Wx_Num, wxNum)
    }
}
```

## 原因分析

先结合Activity看Fragment销毁重建的生命周期，使用 `横竖屏切换` 来模拟Activity被系统回收情况

### 添加

```
I: Activity onCreate: 
I: Activity onResume: 
I: fragment onAttach: 
I: fragment onCreate: 
I: fragment onCreateView: 
I: onCreateView: b1==b2:false
I: fragment onActivityCreated: 
I: fragment onViewStateRestored:
```

### 销毁重建

```
I: fragment onSaveInstanceState:
I: Activity onSaveInstanceState: 
I: fragment onDestroyView: 
I: fragment onDestroy: 
I: fragment onDetach: 
I: Activity onDestroy: 
I: fragment onAttach: 
I: fragment onCreate: 
I: Activity onCreate: 
I: fragment onCreateView: 
I: onCreateView: 
I: fragment onActivityCreated: 
I: fragment onViewStateRestored:
I: Activity onRestoreInstanceState: 
I: Activity onResume: 
```

`onSaveInstanceState` 和 `onRestoreInstanceState` 都被调用了。

### 加入数据

```java
FragmentManager fragmentManager = getSupportFragmentManager();
VDFragment fragment = new VDFragment();
Bundle bundle = new Bundle();
bundle.putString("data", "batman");
fragment.setArguments(bundle);
fragmentManager.beginTransaction()
        .replace(R.id.fl_container, fragment)
        .commit();
```

在Fragment `onCreateView()` 中取数据，并且观察Activity、supportFragmentManager、Fragment、arguments 几个对象的情况

```java
//activity
Log.i(TAG, "Activity onCreate: getSupportFragmentManager hashcode=" + getSupportFragmentManager().hashCode()
+ ",activity hashcode=" + hashCode());

//fragment
static Bundle b1;
static Bundle b2;

Bundle bundle = getArguments();
if (b1 == null) {
    b1 = bundle;
} else {
    b2 = bundle;
    Log.i(TAG, "onCreateView: b1==b2:" + (b1 == b2));
}

if (bundle != null) {
    Log.i("fragment_ts", bundle.getString("data")
            + ",fragment hashcode=" + hashCode()
            + ",bundle hashcode=" + bundle.hashCode()
            + ",activity hashcode=" + getContext().hashCode());
}
```

日志:

```
I: Activity onCreate: getSupportFragmentManager hashcode=42730560,activity hashcode=25396074
I: fragment onCreateView: 
I: onCreateView: b1==b2:true
I: batman,fragment hashcode=141131641,bundle hashcode=161033219,activity hashcode=25396074

I: Activity onCreate: getSupportFragmentManager hashcode=168308313,activity hashcode=34224187
I: fragment onCreateView: 
I: onCreateView: b1==b2:true
I: batman,fragment hashcode=91294238,bundle hashcode=161033219,activity hashcode=34224187

I: Activity onCreate: getSupportFragmentManager hashcode=38793086,activity hashcode=55190968
I: fragment onCreateView: 
I: onCreateView: b1==b2:true
I: batman,fragment hashcode=7703775,bundle hashcode=161033219,activity hashcode=55190968
```

可以看到 `argument` 内存地址和 hashcode 都是相同的，是同一个对象，但是 FragmentManager 、 Activity 、 Fragment 的 hashcode 都不相同，是新对象。

所以数据应该保存在 argument 里面而不是作为属性保存在Fragment里面，不然就需要在 `onSaveInstanceState` 和 `onRestoreInstanceState` 中做处理。

问题是： `argument` 对应的 `Bundle` 是如何保存的呢？

分析思路：

1. 在Fragment的 `onSaveInstanceState` 和 `onRestoreInstanceState` 中 查看关于 mArguments 的内容，并没有有用的发现，线索断裂
2. 既然bundle是赋值给mArguments的，查看有什么地方处理了mArguments，发现内部类 `FragmentState`，从类名就可以察觉这个东西很有嫌疑(这是 support-26 版本的源码，这个版本里面， FragmentState 是 Fragment 的非静态内部类，会持有Fragment的引用造成内存泄露，后面的版本把 FragmentState 拎出去了)
3. 如图不是低版本 support library，只能追溯Fragment宿主Activity的 `onSaveInstanceState()` 了，可以在父类 FragmentActivity 中发现以下代码

```java
protected void onSaveInstanceState(Bundle outState) {
    super.onSaveInstanceState(outState);
    markFragmentsCreated();
    Parcelable p = mFragments.saveAllState();
    if (p != null) {
        outState.putParcelable(FRAGMENTS_TAG, p);
    }
    //...
}
```

mFragments :

```java
final FragmentController mFragments = FragmentController.createController(new HostCallbacks());

//FragmentController
public Parcelable saveAllState() {
        return mHost.mFragmentManager.saveAllState();
    }
```

最后调用到 `FragmentManager#saveAllState()`

```java
//省略部分代码
Parcelable saveAllState() {
    // First collect all active fragments.
    int N = mActive.size();
    FragmentState[] active = new FragmentState[N];
    boolean haveFragments = false;
    for (int i=0; i<N; i++) {
        Fragment f = mActive.valueAt(i);
        FragmentState fs = new FragmentState(f);
        active[i] = fs;
    }
    FragmentManagerState fms = new FragmentManagerState();
    fms.mActive = active;
    fms.mAdded = added;
    fms.mBackStack = backStack;
    if (mPrimaryNav != null) {
        fms.mPrimaryNavActiveIndex = mPrimaryNav.mIndex;
    }
    fms.mNextFragmentIndex = mNextFragmentIndex;
    saveNonConfig();
    return fms;
}
```

所以 FragmentActivity 中用 FRAGMENTS_TAG 保存的实际上是 FragmentManagerState 对象，简称fms。fms 中 active 数组保存 FragmentState 对象，FragmentState 中保存 Fragment状态。

```java
//FragmentState
FragmentState(Fragment frag) {
    mClassName = frag.getClass().getName();
    mIndex = frag.mIndex;
    mFromLayout = frag.mFromLayout;
    mFragmentId = frag.mFragmentId;
    mContainerId = frag.mContainerId;
    mTag = frag.mTag;
    mRetainInstance = frag.mRetainInstance;
    mDetached = frag.mDetached;
    mArguments = frag.mArguments;
    mHidden = frag.mHidden;
}
```

数据恢复

从 `onRestoreInstanceState()` 开始，可以直接从 FragmentActivity 开始看了。

```java
public void onRestoreInstanceState(Bundle savedInstanceState,
            PersistableBundle persistentState) {
    if (savedInstanceState != null) {
        onRestoreInstanceState(savedInstanceState);
    }
}
```

嗯，没有。看看父类呢

```java
protected void onRestoreInstanceState(Bundle savedInstanceState) {
    if (mWindow != null) {
        Bundle windowState = savedInstanceState.getBundle(WINDOW_HIERARCHY_TAG);
        if (windowState != null) {
            mWindow.restoreHierarchyState(windowState);
        }
    }
}
```

还是没有。 great !

既然 FragmentActivity 中是通过 `mFragments` 间接操作 FragmentManager 的，那直接找 `mFragments` 的所有调用位置，或者搜 `mFragments.restore` 好了。

在 `onCreate()` 找到了。

```java

protected void onCreate(@Nullable Bundle savedInstanceState) {
    this.mFragments.attachHost((Fragment)null);
    super.onCreate(savedInstanceState);

    NonConfigurationInstances nc =
            (NonConfigurationInstances) getLastNonConfigurationInstance();
    if (nc != null) {
        mViewModelStore = nc.viewModelStore;
    }

    if (savedInstanceState != null) {
        Parcelable p = savedInstanceState.getParcelable("android:support:fragments");
        this.mFragments.restoreAllState(p, nc != null ? nc.fragments : null);
    }

    //重走Fragment create 生命周期
    this.mFragments.dispatchCreate();
}
```

看 FragmentManager

```java
void restoreAllState(Parcelable state, FragmentManagerNonConfig nonConfig) {
    // If there is no saved state at all, then there can not be
    // any nonConfig fragments either, so that is that.
    if (state == null) return;
    FragmentManagerState fms = (FragmentManagerState)state;
    if (fms.mActive == null) return;

    // Build the full list of active fragments, instantiating them from
    // their saved state.
    mActive = new SparseArray<>(fms.mActive.length);
    for (int i=0; i<fms.mActive.length; i++) {
        FragmentState fs = fms.mActive[i];
        if (fs != null) {
            FragmentManagerNonConfig childNonConfig = null;
            if (childNonConfigs != null && i < childNonConfigs.size()) {
                childNonConfig = childNonConfigs.get(i);
            }
            //重新创建Fragment对象
            Fragment f = fs.instantiate(mHost, mContainer, mParent, childNonConfig,
                    viewModelStore);
            
            mActive.put(f.mIndex, f);
            // Now that the fragment is instantiated (or came from being
            // retained above), clear mInstance in case we end up re-restoring
            // from this FragmentState again.
            fs.mInstance = null;
        }
    }
}
```

在这里恢复Fragment栈，并把 savedInstanceState 里面保存的 FragmentManagerState 序列化对象重新创建，因为 mActive 数组里面只是保存 FragmentState 对象的堆地址，所以 FragmentState 对象并没有重新创建，所以里面保存的 argument 也没有重新创建。

[源码](https://github.com/AmoryPepelu/Ladybird/blob/master/AndroidHunter/ViewDemo/app/src/main/java/github/amorypepelu/viewdemo/fragment/FragmentActivity.java)

the end .
