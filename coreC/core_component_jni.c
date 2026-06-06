#include <jni.h>
#include <stdlib.h>
#include "core_component.h"

// Replace "com_example_myapp" with your Android app's actual package (using underscores)
JNIEXPORT jstring JNICALL
Java_com_example_myapplication_NativeCore_getNativeVersion(JNIEnv *env, jobject thiz) {

    char buffer[32]; // Buffer to store "X.Y.Z"
    
    // We call your original ANSI C function
    int result = getVersion(buffer, sizeof(buffer));
    
    if (result == VERSION_SUCCESS) {
        // We convert the C char* to a Java/Kotlin jstring
        return (*env)->NewStringUTF(env, buffer);
    } else {
        return (*env)->NewStringUTF(env, "Error: Insufficient buffer");
    }
}