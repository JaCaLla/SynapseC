package com.example.myapplication

object NativeCore {
    init {
        // Loads the .so library. Note that the "lib" prefix and the ".so" extension are omitted
        System.loadLibrary("core_component_c_shared")
    }

    /**
     * Declares the native method. The 'external' keyword indicates
     * to Kotlin that the implementation is in native code (C/C++).
     */
    external fun getNativeVersion(): String
}