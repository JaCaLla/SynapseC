#!/bin/bash
set -e

# 0. Assure script is run from its own directory (robustly)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# 1. Clean up previous artifacts
echo "🧹 Cleaning up previous builds..."
rm -rf "$SCRIPT_DIR/build_ios" \
       "$SCRIPT_DIR/build_sim_arm" \
       "$SCRIPT_DIR/build_sim_x86" \
       "$SCRIPT_DIR/build_xcf" \
       "$SCRIPT_DIR/CoreC.xcframework" \
       "$SCRIPT_DIR/Package.swift"

# 2. Compile for Physical Device (iOS arm64) using native Makefiles
echo "📱 Compiling for iOS device (arm64)..."
cmake -B "$SCRIPT_DIR/build_ios" \
  -G "Unix Makefiles" \
  -DCMAKE_SYSTEM_NAME=iOS \
  -DCMAKE_OSX_ARCHITECTURES=arm64 \
  -DCMAKE_BUILD_TYPE=Release > /dev/null 2>&1

cmake --build "$SCRIPT_DIR/build_ios" --target core_c_lib --config Release
echo "✅ iOS device built successfully!"

# 3. Compile for Simulator (arm64)
echo "💻 Compiling for iOS Simulator (arm64)..."
cmake -B "$SCRIPT_DIR/build_sim_arm" \
  -G "Unix Makefiles" \
  -DCMAKE_SYSTEM_NAME=iOS \
  -DCMAKE_OSX_SYSROOT=iphonesimulator \
  -DCMAKE_OSX_ARCHITECTURES=arm64 \
  -DCMAKE_BUILD_TYPE=Release > /dev/null 2>&1

cmake --build "$SCRIPT_DIR/build_sim_arm" --target core_c_lib --config Release > /dev/null 2>&1

# 4. Compile for Simulator (x86_64)
echo "💻 Compiling for iOS Simulator (x86_64)..."
cmake -B "$SCRIPT_DIR/build_sim_x86" \
  -G "Unix Makefiles" \
  -DCMAKE_SYSTEM_NAME=iOS \
  -DCMAKE_OSX_SYSROOT=iphonesimulator \
  -DCMAKE_OSX_ARCHITECTURES=x86_64 \
  -DCMAKE_BUILD_TYPE=Release > /dev/null 2>&1

cmake --build "$SCRIPT_DIR/build_sim_x86" --target core_c_lib --config Release > /dev/null 2>&1
echo "✅ iOS Simulators built successfully!"

# 5. Merge simulator architectures and prepare environments
echo "🔍 Processing and merging simulator architectures..."
mkdir -p "$SCRIPT_DIR/build_xcf/products/ios" \
         "$SCRIPT_DIR/build_xcf/products/sim" \
         "$SCRIPT_DIR/build_xcf/headers"

# With "Unix Makefiles", CMake outputs .a files EXACTLY at the root of each build folder.
LIB_IOS="$SCRIPT_DIR/build_ios/libcore_c_lib.a"
LIB_SIM_ARM="$SCRIPT_DIR/build_sim_arm/libcore_c_lib.a"
LIB_SIM_X86="$SCRIPT_DIR/build_sim_x86/libcore_c_lib.a"

# Ensure physical device library is copied
cp "$LIB_IOS" "$SCRIPT_DIR/build_xcf/products/ios/libcore_c_lib.a"

# Create the universal binary for the simulator
lipo -create "$LIB_SIM_ARM" "$LIB_SIM_X86" -output "$SCRIPT_DIR/build_xcf/products/sim/libcore_c_lib.a"

# Copy the public header
cp "$SCRIPT_DIR/core_component.h" "$SCRIPT_DIR/build_xcf/headers/"

# Crear el mapa de módulo para que Swift reconozca la librería C
cat << 'EOF' > "$SCRIPT_DIR/build_xcf/headers/module.modulemap"
module CoreC {
    header "core_component.h"
    export *
}
EOF

# 6. Create the temporary XCFramework in the build directory
echo "🚀 Packaging into CoreC.xcframework..."
xcodebuild -create-xcframework \
  -library "$SCRIPT_DIR/build_xcf/products/ios/libcore_c_lib.a" -headers "$SCRIPT_DIR/build_xcf/headers" \
  -library "$SCRIPT_DIR/build_xcf/products/sim/libcore_c_lib.a" -headers "$SCRIPT_DIR/build_xcf/headers" \
  -output "$SCRIPT_DIR/build_xcf/CoreC.xcframework"

# 7. Organize the definitive isolated SPM environment (Isolate from source code)
echo "📦 Organizing isolated Swift Package Manager environment..."
SPM_DIR="$SCRIPT_DIR/build_xcf/spm"
mkdir -p "$SPM_DIR"

# Move the generated .xcframework into the spm directory
mv "$SCRIPT_DIR/build_xcf/CoreC.xcframework" "$SPM_DIR/"

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