package com.project5e.example.pictureselector;

import android.content.Intent
import android.os.Bundle
import android.util.Log
import com.project5e.react.navigation.view.RnRootActivity
import io.project5e.lib.media.model.GalleryViewModel
import io.project5e.lib.media.model.LocalMedia
import io.project5e.lib.media.utils.ViewModelProviders
import kotlin.collections.ArrayList

class MainActivity : RnRootActivity() {

  /**
   * Returns the name of the main component registered from JavaScript. This is used to schedule
   * rendering of the component.
   */
  override fun getMainComponentName(): String = "AwesomeMedialibExample"

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    val model = ViewModelProviders.of(this).get(GalleryViewModel::class.java)
    model.nextStep.observe(this) {
      if (it != true) return@observe
      val intent = Intent(this, NativeNextActivity::class.java)
      val allSelected = model.getAllSelected()
      allSelected ?: return@observe
      val temp: ArrayList<LocalMedia> = arrayListOf()
      temp.addAll(allSelected)
      intent.putExtra("allSelected", temp)
      // startActivity(intent)
    }
  }

}
