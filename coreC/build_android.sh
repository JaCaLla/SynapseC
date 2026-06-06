#!/bin/bash
set -e

# 1. Define the base path of the Android SDK on your Mac
SDK_PATH="$HOME/Library/Android/sdk"

# 2. Automatically detect the highest installed NDK version
if [ -d "$SDK_PATH/ndk" ]; then
    NDK_VERSION=$(ls -1 "$SDK_PATH/ndk" | sort -V | tail -n 1)
    NDK_PATH="$SDK_PATH/ndk/$NDK_VERSION"
else
    echo "❌ Error: 'ndk' folder not found at $SDK_PATH/ndk"
    exit 1
fi

TOOLCHAIN="$NDK_PATH/build/cmake/android.toolchain.cmake"

echo "🤖 NDK Automatically detected at: $NDK_PATH"
echo "📄 Toolchain: $TOOLCHAIN"

# 3. Path configuration for the Multiplatform Project
# Since the script runs from 'common/', we go up one level and enter AndroidApp
ANDROID_APP_JNI_DIR="../AndroidApp/app/src/main/jniLibs"

ARCHS=("armeabi-v7a" "arm64-v8a" "x86" "x86_64")
ANDROID_API=21

echo "🧹 Cleaning up previous local builds and target directories in AndroidApp..."
rm -rf build_android jniLibs
rm -rf "$ANDROID_APP_JNI_DIR"

# Ensure target folders exist
mkdir -p jniLibs
mkdir -p "$ANDROID_APP_JNI_DIR"

for ARCH in "${ARCHS[@]}"
do
    echo "------------------------------------------------"
    echo "🤖 Generating environment for: $ARCH..."
    mkdir -p "build_android/$ARCH"
    
    cmake -B "build_android/$ARCH" \
          -DCMAKE_TOOLCHAIN_FILE="$TOOLCHAIN" \
          -DANDROID_ABI="$ARCH" \
          -DANDROID_PLATFORM=android-$ANDROID_API \
          -DCMAKE_BUILD_TYPE=Release > /dev/null 2>&1

    echo "🛠️ Compiling private binary ($ARCH)..."
    cmake --build "build_android/$ARCH" --target core_component_c_shared --config Release > /dev/null 2>&1
    
    # Locate the newly created .so file
    SO_FILE=$(find "build_android/$ARCH" -name "libcore_component_c_shared.so" | head -n 1)
    
    if [ -z "$SO_FILE" ]; then
        echo "❌ Error: The .so file was not generated for $ARCH"
        exit 1
    fi
    
    # Copy 1: Local backup in the 'coreC/jniLibs' folder
    mkdir -p "jniLibs/$ARCH"
    cp "$SO_FILE" "jniLibs/$ARCH/"
    
    # Copy 2: Direct deployment into the AndroidApp directory structure
    mkdir -p "$ANDROID_APP_JNI_DIR/$ARCH"
    cp "$SO_FILE" "$ANDROID_APP_JNI_DIR/$ARCH/"
    
    echo "✅ Binary for $ARCH successfully copied to AndroidApp."
done

echo "------------------------------------------------"
echo "🎉 ABSOLUTE VICTORY! Process completed."
echo "🚀 The private binaries are ready at: $ANDROID_APP_JNI_DIR"