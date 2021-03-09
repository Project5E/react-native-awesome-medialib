package com.project5e.example.pictureselector

import android.app.Application
import android.content.Context
import com.facebook.react.*
import com.facebook.soloader.SoLoader
import com.project5e.react.navigation.NavigationManager
import io.project5e.lib.media.MediaLibManager
import io.project5e.lib.media.MediaLibPackage
import io.project5e.lib.media.manager.LocalMediaManager

class MainApplication : Application(), ReactApplication {
  private val mReactNativeHost: ReactNativeHost = object : ReactNativeHost(this) {
    override fun getUseDeveloperSupport(): Boolean {
      return BuildConfig.DEBUG
    }

    override fun getPackages(): List<ReactPackage> {
      return PackageList(this).packages
    }

    override fun getJSMainModuleName(): String {
      return "index"
    }
  }

  override fun getReactNativeHost(): ReactNativeHost {
    return mReactNativeHost
  }

  override fun onCreate() {
    super.onCreate()
    SoLoader.init(this,  /* native exopackage */false)
    initializeFlipper(this, reactNativeHost.reactInstanceManager) // Remove this line if you don't want Flipper enabled
    MediaLibManager.install(this@MainApplication, reactNativeHost.reactInstanceManager)
    NavigationManager.install(mReactNativeHost)
    // NavigationManager.TAG = "sy_test_bug"
  }

  companion object {
    /**
     * Loads Flipper in React Native templates.
     *
     * @param context
     */
    private fun initializeFlipper(context: Context, reactInstanceManager: ReactInstanceManager) {
      if (BuildConfig.DEBUG) {
        try {
          /*
         We use reflection here to pick up the class that initializes Flipper,
        since Flipper library is not available in release mode
        */
          val aClass = Class.forName("com.project5e.example.pictureselector.ReactNativeFlipper")
          aClass
            .getMethod("initializeFlipper", Context::class.java, ReactInstanceManager::class.java)
            .invoke(null, context, reactInstanceManager)
        } catch (e: Exception) {
          e.printStackTrace()
        }
      }
    }
  }
}
