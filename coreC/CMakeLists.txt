cmake_minimum_required(VERSION 3.22.1)
project(CoreC C)

# ==========================================
# 1. SHARED CONFIGURATION (iOS / LOCAL)
# ==========================================

# We create the pure static library for iOS and tests
add_library(core_c_lib STATIC core_component.c)

# Your current executable for local testing remains exactly the same
add_executable(programa_test main.c)
target_link_libraries(programa_test PRIVATE core_c_lib)

# ==========================================
# 2. EXCLUSIVE CONFIGURATION FOR ANDROID
# ==========================================
# If CMake is invoked by the Android script, this variable is automatically activated
if(ANDROID)
    message(STATUS "🤖 Configuring Android-specific compilation...")

    # Force public visibility so that JNI can find the bridge functions
    set(CMAKE_C_VISIBILITY_PRESET default)

    # Search for the internal JNI dependencies provided by the Android NDK
    find_package(JNI REQUIRED)

    # Create the SHARED library (.so) exclusive for Android
    # It includes your algorithm (core_component.c) and the bridge (core_component_jni.c)
    add_library(core_component_c_shared SHARED 
        core_component.c 
        core_component_jni.c
    )

    # Link the native Android logging library (in case you need to use the console)
    target_link_libraries(core_component_c_shared PRIVATE log)
endif()