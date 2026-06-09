
# SynapseC - Multiplatform Native C Core Ecosystem

A multi-part project demonstrating how to build, encapsulate, and reuse a single, pure **ANSI C native core component** across entirely different platform architectures: **iOS**, **Android**, and a cloud-hosted **Dockerized Vapor Backend**.

---

## 🗺️ Project Roadmap

This ecosystem is divided into three distinct integration phases, all powered by the exact same underlying native C logic:

* **Phase 1: iOS Integration (SPM Wrapper)** 🟢 - Exposing the C API safely to Swift using Swift Package Manager. Explained step by step process in [Multiplatform ANSI C on iOS](https://javios.eu/architecture/how-to-compile-c-logic-for-the-ios-ecosystem-synapsec-1-3/) post
* **Phase 2: Android App (JNI Wrapper)**  🟢  - Bridging the C core to Kotlin using the Java Native Interface. Explained step by step process in [Multiplatform ANSI C on Android (and iOS)](https://javios.eu/architecture/multiplatform-ansi-c-on-android-and-ios/) post
* **Phase 3: Backend Server (Docker/Vapor)** 🟢  - Embedding the C component inside a Swift-based server running on Docker. Explained step by step process in  [Dockerizing a C Component with Vapor](https://javios.eu/architecture/hosting-a-shared-ansi-c-component-on-a-vapor-server-dockerized/) 

---

##  Phase 1: iOS Integration & SPM Wrapper

### 🛠️ Compilation & Local Build

Before the Swift Package Manager (SPM) wrapper can resolve the native component, you need to compile the C source into a binary format (`.xcframework`). 

Navigate to the `coreC` directory and execute the compilation script:

```bash
# 1. Navigate to the native core directory
cd SynapseC/coreC

# 2. Run the build script to generate the XCFramework
./build_xcframework.sh

```
Once executed, the script automatically deploys the compiled package to `SynapseC/coreC/biuld_xcf/spm`. From there, you simply need to import this directory directly into your Xcode project.

## 🤖 Phase 2: Android integration

### 🛠️ Compilation & Local Build

Before the Swift Package Manager (SPM) wrapper can resolve the native component, you need to compile the C source into a binary format (`.xcframework`). 

Navigate to the `coreC` directory and execute the compilation script:

```bash
# 1. Navigate to the native core directory
cd SynapseC/coreC

# 2. Run the build script to generate the XCFramework
./build_android.sh

```
Once executed, it locates each generated .so file and copies it to two destinations: a local backup directory (jniLibs) and directly into the Android project’s source tree (app/src/main/jniLibs), ensuring that the Android app has all the native binaries it needs for cross-platform hardware compatibility


## 💧 Phase 3: Dockerized Vapor backend server

### 🛠️ Develop & Debug

For develop an debug backend project:

Navigate to the `coreC` directory and execute the compilation script:

```bash
# 1. Navigate to the native core directory
cd SynapseC/coreC

# 2. Run the build script to generate binaries for being consumed by Vapor project
./build_vapor_mac.sh

```
Once executed, it compiles your native C library into a static binary (libcore_component.a) using gcc and ar. It then deploys both the compiled library and its header file directly into a Swift Vapor backend project following native Swift Package Manager standards.

### 🚢🐳 Deploy 

Before the Swift Package Manager (SPM) wrapper can resolve the native component, you need to compile the C source into a binary format (`.xcframework`). 

Navigate to the `coreC` directory and execute the compilation script:

```bash
# 1. Navigate to the native core directory
cd SynapseC/coreC

# 2. Run the build script to generate the XCFramework
./build_linux.sh

```
Once executed, it compiles your native C library into a Linux-compatible static binary (libcore_component.a) using gcc with position-independent code enabled. It then deploys this compiled library along with its header file directly into a Swift Vapor backend project following the official Swift Package Manager target structure.

```bash
# 3. Move back to parent folder
cd ..

# 2. Build image
docker build -t swift-backend-app -f SwiftBackend/Dockerfile .

# 3. Deploy container
docker run -d -p 8080:8080 --name mi-servidor-vapor swift-backend-app

# 4. Call the service
curl -i "http://localhost:8080/version"

```
