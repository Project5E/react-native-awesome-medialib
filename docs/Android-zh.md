# 开始([English](https://github.com/Project5E/react-native-awesome-medialib/doc/Android.md))
<br/>

## 使用
### 1. 在 `Application` 文件中，安装`MediaLibManager`
```kotlin
// YourApplication.kt
  override fun onCreate() {
    super.onCreate()
    ...
    MediaLibManager.install(this, reactNativeHost.reactInstanceManager)
  }

```
<br/>


### 2. 可选项: 你可以在装载图片选择器的容器中，观察名为 `nextStep` 的 LiveData, 以从原生的方式获取图片选择器的结果。
<font face="黑体" color="#ff0000" size=3>注意: 获取结果的方式只能使用一种(原生获取或者react-native获取二选一)</font>
<br/>

```kotlin
  ...
  // (1) 获取 GalleryViewModel 对象, 其中 ViewModelProviders/GalleryViewModel 都是本库中的API
  val model = ViewModelProviders.of(this).get(GalleryViewModel::class.java)
  // (2) 观察 nextStep
  model.nextStep.observe(this) {
      if (it != true) return@observe
      // (3) 获取所有的被选项的列表
      val allSelected = model.getAllSelected()
      allSelected ?: return@observe
      // (4) 执行业务操作,
      openANewNativePage(allSelected)
    }
  
  private fun openANewNativePage(temp: List<LocalMedia>) {
    val intent = Intent(this, NativeNextActivity::class.java)
    val data: ArrayList<LocalMedia> = arrayListOf()
    data.addAll(temp)
    intent.putExtra("data", data)
    startActivity(intent)
  }
  ...
```
<br/>


### 3. 可选项: 以react native的方式获取图片选择器的结果
  [详见README 使用/第3点](https://github.com/Project5E/react-native-awesome-medialib/README.md)
<br/>

## End