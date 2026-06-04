#!/bin/bash
set -e

# 1. Clean up previous artifacts
echo "🧹 Cleaning up previous builds..."
rm -rf build_ios build_sim_arm build_sim_x86 build_xcf CoreC.xcframework Package.swift

# 2. Compile for Physical Device (iOS arm64) using native Makefiles
echo "📱 Compiling for iOS device (arm64)..."
cmake -B build_ios \
  -G "Unix Makefiles" \
  -DCMAKE_SYSTEM_NAME=iOS \
  -DCMAKE_OSX_ARCHITECTURES=arm64 \
  -DCMAKE_BUILD_TYPE=Release > /dev/null 2>&1

cmake --build build_ios --target core_c_lib --config Release
echo "✅ iOS device built successfully!"

# 3. Compile for Simulator (arm64)
echo "💻 Compiling for iOS Simulator (arm64)..."
cmake -B build_sim_arm \
  -G "Unix Makefiles" \
  -DCMAKE_SYSTEM_NAME=iOS \
  -DCMAKE_OSX_SYSROOT=iphonesimulator \
  -DCMAKE_OSX_ARCHITECTURES=arm64 \
  -DCMAKE_BUILD_TYPE=Release > /dev/null 2>&1

cmake --build build_sim_arm --target core_c_lib --config Release > /dev/null 2>&1

# 4. Compile for Simulator (x86_64)
echo "💻 Compiling for iOS Simulator (x86_64)..."
cmake -B build_sim_x86 \
  -G "Unix Makefiles" \
  -DCMAKE_SYSTEM_NAME=iOS \
  -DCMAKE_OSX_SYSROOT=iphonesimulator \
  -DCMAKE_OSX_ARCHITECTURES=x86_64 \
  -DCMAKE_BUILD_TYPE=Release > /dev/null 2>&1

cmake --build build_sim_x86 --target core_c_lib --config Release > /dev/null 2>&1
echo "✅ iOS Simulators built successfully!"

# 5. Merge simulator architectures and prepare environments
echo "🔍 Processing and merging simulator architectures..."
mkdir -p build_xcf/products/ios build_xcf/products/sim build_xcf/headers

# With "Unix Makefiles", CMake outputs .a files EXACTLY at the root of each build folder.
LIB_IOS="build_ios/libcore_c_lib.a"
LIB_SIM_ARM="build_sim_arm/libcore_c_lib.a"
LIB_SIM_X86="build_sim_x86/libcore_c_lib.a"

# Ensure physical device library is copied
cp "$LIB_IOS" build_xcf/products/ios/libcore_c_lib.a

# Create the universal binary for the simulator
lipo -create "$LIB_SIM_ARM" "$LIB_SIM_X86" -output build_xcf/products/sim/libcore_c_lib.a

# Copy the public header
cp core_component.h build_xcf/headers/

cat << 'EOF' > build_xcf/headers/module.modulemap
module CoreC {
    header "core_component.h"
    export *
}
EOF

# 6. Create the temporary XCFramework in the build directory
echo "🚀 Packaging into CoreC.xcframework..."
xcodebuild -create-xcframework \
  -library build_xcf/products/ios/libcore_c_lib.a -headers build_xcf/headers \
  -library build_xcf/products/sim/libcore_c_lib.a -headers build_xcf/headers \
  -output build_xcf/CoreC.xcframework

# 7. Organize the definitive isolated SPM environment (Isolate from source code)
echo "📦 Organizing isolated Swift Package Manager environment..."
SPM_DIR="build_xcf/spm"
mkdir -p "$SPM_DIR"

# Move the generated .xcframework into the spm directory
mv build_xcf/CoreC.xcframework "$SPM_DIR/"

# Dynamically generate the Package.swift DIRECTLY inside the spm directory
cat << 'EOF' > "$SPM_DIR/Package.swift"
// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "CoreC",
    products: [
        .library(name: "CoreC", targets: ["CoreC"])
    ],
    targets: [
        .binaryTarget(
            name: "CoreC",
            path: "CoreC.xcframework" // Path relative to Package.swift
        )
    ]
)
EOF

echo "🎉 ABSOLUTE VICTORY! Your isolated SPM is ready at: $SPM_DIR"