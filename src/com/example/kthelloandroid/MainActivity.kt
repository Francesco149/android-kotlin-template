package com.example.kthelloandroid

import android.app.Activity
import android.os.Bundle
import android.util.Log
import android.widget.RelativeLayout
import android.widget.TextView
import android.view.Gravity

class MainActivity : Activity() {
  companion object {
    private val TAG = this::class.java.simpleName
  }

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    val layout = RelativeLayout(this)
    val params = RelativeLayout.LayoutParams(
      RelativeLayout.LayoutParams.MATCH_PARENT,
      RelativeLayout.LayoutParams.MATCH_PARENT)
    layout.setLayoutParams(params)
    val helloTextView = TextView(this)
    helloTextView.setGravity(Gravity.CENTER)
    helloTextView.setTextSize(24.0f)
    helloTextView.setText("hello world")
    layout.addView(helloTextView)
    setContentView(layout)
    Log.d(TAG, "hello world")
  }
}
