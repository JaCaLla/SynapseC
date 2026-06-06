package com.example.myapplication

object NativeCore {
    init {
        // Carga la librería .so. Nota que se descarta el prefijo "lib" y la extensión ".so"
        System.loadLibrary("core_component_c_shared")
    }

    /**
     * Declara el método nativo. La palabra clave 'external' indica
     * a Kotlin que la implementación está en código nativo (C/C++).
     */
    external fun getNativeVersion(): String
}