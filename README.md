# Get Started([中文](https://github.com/Project5E/react-native-awesome-medialib/doc/README-zh.md))

A useful media selector module base on native component. It will offer a meida selector in batteries-included way, including picture selection, photo shooting, video selection, album switch, preview and so on. We recommend strongly that u should install reac-native-awesome-navigation as navigation component in project when using this lib.

## Installation

Using yarn
```sh 
yarn add react-native-awesome-medialib
```
or using npm
```sh
npm install react-native-awesome-medialib
```

U need install all of following libraries:<br/>
(1) [react-native-awesome-navigation](https://github.com/Project5E/react-native-awesome-navigation),<br/>
(2) [react-native-fast-image](https://github.com/DylanVann/react-native-fast-image),<br/>
(3) [react-native-gesture-handler](https://github.com/software-mansion/react-native-gesture-handler),<br/>
(4) [react-native-iphone-x-helper](https://github.com/ptelad/react-native-iphone-x-helper),<br/>
(5) [react-native-root-toast](https://github.com/magicismight/react-native-root-toast),<br/>
(6) [@types/react-native-video](https://github.com/react-native-video/react-native-video) and [react-native-video](https://github.com/react-native-video/react-native-video).<br/>
<br/>

## Build configuration on Android
Ensure your build files match the following requirements:
### 1. (React Native 0.59 and lower) Define the `react-native-awesome-medialib` project in android/settings.gradle:
```kotlin
// settings.gradle
include ':react-native-awesome-medialib'
project(':react-native-awesome-medialib').projectDir = new File(rootProject.projectDir, '../node_modules/react-native-awesome-medialib/android')
```
<br/>

### 2. (React Native 0.59 and lower) Add the `react-native-awesome-medialib` as an dependency of your app in android/app/build.gradle:
```kotlin
// app/build.gradle
dependency {
  ...
  implementation project(':react-native-awesome-medialib')
  ...
}
```
<br/>

### 3. maunully add ReactPackage to PackageList in Application:
```kotlin
class MainApplication : Application(), ReactApplication {
    private val mReactNativeHost: ReactNativeHost = object : ReactNativeHost(this) {
        ...
        override fun getPackages(): List<ReactPackage> {
            val packages: MutableList<ReactPackage> = PackageList(this).packages
            packages.add(MediaLibPackage())
            return packages
        }
    }
    ...
}
```
<br/>

## Build configuration on iOS
Using React Native Link (React Native 0.59 and lower)<br/>
Run
```sh
react-native link react-native-awesome-medialib
```
after which you should be able to use this library on iOS.
<br/>
<br/>

## Documentation
- [Android](https://github.com/Project5E/react-native-awesome-medialib/doc/Android.md)
<br/>
- [iOS](https://github.com/Project5E/react-native-awesome-medialib/doc/iOS.md)
<br/>

## Usage
### 1. First of all, use {#Register.registerComponent} make all page had been registed. 
<br/>
> u also can use other navigation lib such as `react-navigation`, and register by it. but we recommond use `react-native-awesome-navigation`, because media lib internal page's navigate is used it.

```typescript
// registing.tsx
import {
  MediaSelectorPage,
  MediaLibraryPage,
  CameraPage,
  MediaLibraryPhotoPreviewPage,
  PhotoPreviewPage,
  VideoPreviewPage,
} from 'react-native-awesome-medialib'
import {Register} from 'react-native-awesome-navigation'

// ...

export const registing = async () => {
  Register.beforeRegister()

  Register.registerComponent('Your MediaLib enter page name', `Your MediaLib enter page`)
  Register.registerComponent('MediaSelectorPage', MediaSelectorPage)
  Register.registerComponent('CameraPage', CameraPage)
  Register.registerComponent('PhotoPreviewPage', PhotoPreviewPage)
  Register.registerComponent('MediaLibraryPage', MediaLibraryPage)
  Register.registerComponent('VideoPreviewPage', VideoPreviewPage)
  Register.registerComponent('MediaLibraryPhotoPreviewPage', MediaLibraryPhotoPreviewPage)
}

// index.tsx
import {registing} from '...'

registing()
```
<br/>

### 2. Secondly, navigate to 'MediaSelectorPage' in ur media library entrance. 
```typescript
// some place
const onPress() = () => {
  // react-native-awesome-navigation (u should refer to their documentation!)
  props.navigator.push('MediaSelectorPage')
  // react-navigation and others (u should refer to their documentation!)
  navigation.push...
}

return (
  <>
    ...
    <SomeView onPress={onPress} ...>...</SomeView>
    ...
  </>
)
```
<br/>

### 3. Then, get result by listening event in ur entrance of medialib, and the event value is type of `Result` from this library.
```typescript
  // Ur entrance of medialib
  useEffect(() => {
    const subs = rxEventBus.listen(OnNextStepNotification).subscribe(value => {
      // e.g. push this value to new page do something or other operation
      props.navigator.push('Your results display page', value)
    })
    return () => {
      subs.unsubscribe()
    }
  }, [props])
```
<br/>

The type of result: ur can get a list of choosen images or a video, whitch is include id(android media strore id,), url(above android 10 is "content:\\\\...", otherwise absolute path),width, height, type, scale and so on.
```typescript
  // ResultModel.ts
  export interface LocalMedia {
  id?: number
  url: string
  width?: number
  height?: number
  scale?: number
  type?: SourceType
}

export enum InvokeType {
  main = 'main',
  editor = 'editor',
  avatar = 'avatar',
}

export enum SourceType {
  image = 'image',
  video = 'video',
}

export interface Result {
  dataList: LocalMedia[]
  from?: InvokeType
}
```
<br/>

### 4. Last, Enjoy it!
<br/>
## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT
