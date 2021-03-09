package com.project5e.example.pictureselector

import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.widget.TextView
import io.project5e.lib.media.model.LocalMedia

class NativeNextActivity : AppCompatActivity() {

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    setContentView(R.layout.activity_native_next)
    val data = intent.getParcelableArrayListExtra<LocalMedia>("allSelected")
    val tv: TextView = findViewById(R.id.tv_data)
    val content = getString(R.string.result, data)
    tv.text = content
  }
}
