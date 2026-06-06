package com.example.myapplication

import android.app.Activity
import android.os.Bundle
import android.widget.TextView

class MainActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        val versionDesdeC = NativeCore.getNativeVersion()

        findViewById<TextView>(R.id.myTextView).text = "Version CoreC: $versionDesdeC"
    }
}