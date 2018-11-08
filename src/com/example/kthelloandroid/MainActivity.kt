package com.example.kthelloandroid

import android.app.Activity
import android.os.Bundle
import android.util.Log
import android.widget.RelativeLayout
import android.widget.TextView
import android.view.Gravity

class MainActivity : Activity() {
  private val TAG = this::class.java.name

  val helloTextView by lazy {
    val x = TextView(this)
    x.setGravity(Gravity.CENTER)
    x.setTextSize(24.0f)
    x.setText("hello world")
    x
  }

  val layout by lazy {
    val x = RelativeLayout(this)
    x.addView(helloTextView)
    x
  }

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    setContentView(layout)
    Log.d(TAG, "hello world")
  }
}
