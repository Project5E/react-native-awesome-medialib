# Get Start([中文](https://github.com/Project5E/react-native-awesome-medialib/doc/Android-zh.md))
<br/>

## Usage
### 1. Install `MediaLibManager` in ur `Application`
```kotlin
// YourApplication.kt
  override fun onCreate() {
    super.onCreate()
    ...
    MediaLibManager.install(this, reactNativeHost.reactInstanceManager)
  }

```
<br/>

### 2. Optional: Get results in native way.
U can observe a signal in ur 'MediaLib' container(maybe a activity or a fragment) to get selector result list.
<br/>
<font face="黑体" style=bold size=4 color=red>U must choose one between Point.2 and Point.3</font>

```kotlin
  ...
  // (1) get GalleryViewModel
  val model = ViewModelProviders.of(this).get(GalleryViewModel::class.java)
  // (2) observe nextStep
  model.nextStep.observe(this) {
      if (it != true) return@observe
      // (3) obtain all selected item
      val allSelected = model.getAllSelected()
      allSelected ?: return@observe
      // (4) for example: open a new native page
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

### 3. Optional: Get results in react-native way:
  [for more detail:README Usage Point.3]:(https://github.com/Project5E/react-native-awesome-medialib/README.md)

## End