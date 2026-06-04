
# SynampseC - Multiplatform Native C Core Ecosystem

A multi-part project demonstrating how to build, encapsulate, and reuse a single, pure **ANSI C native core component** across entirely different platform architectures: **iOS**, **Android**, and a cloud-hosted **Dockerized Vapor Backend**.

---

## 🗺️ Project Roadmap

This ecosystem is divided into three distinct integration phases, all powered by the exact same underlying native C logic:

* **Phase 1: iOS Integration (SPM Wrapper)** 🟢 *[Current]* - Exposing the C API safely to Swift using Swift Package Manager.
* **Phase 2: Android App (JNI Wrapper)** 🟡 *[Coming Soon]* - Bridging the C core to Kotlin using the Java Native Interface.
* **Phase 3: Backend Server (Docker/Vapor)** 🟡 *[Coming Soon]* - Embedding the C component inside a Swift-based server running on Docker.

---

## 🚀 Phase 1: iOS Integration & SPM Wrapper

This directory contains the iOS implementation. Instead of exposing unsafe raw C pointers, allocations, and manual memory management to the main app, we implement a **Swift Package Manager (SPM) Wrapper**. 

This approach isolates the C boundary, handling data conversion and status codes internally to expose a clean, modern, and type-safe "Swifty" API.

### Key Architecture Benefits

* **Zero Boilerplate in App Logic:** The application consumer never deals with C-style memory allocations (`[Int8]` buffers) or raw pointers.
* **Encapsulated C Types:** Deciphers cryptic integer status codes (e.g., `0` for success, `-1` for insufficient buffer) and translates them into native Swift types or meaningful errors.
* **Explicit Shadow Prevention:** The wrapper isolates the global ANSI C function names (like `getVersion`) by wrapping them into idiomatic Swift methods (like `fetchVersion()`), preventing namespace collisions.

---

## 🛠️ Implementation Detail

The core interaction showcases how an incoming byte-array pointer from ANSI C is safely prepared, populated, and decoded into a native Swift string boundary:

```swift
import Foundation
import CoreC

struct CoreCWrapper {
    
    /// Safe Swift wrapper for the ANSI C function 'getVersion'
    /// Renamed to 'fetchVersion()' to avoid shadowing the global C function name.
    static func fetchVersion() -> String {
        // 1. Allocate a byte array with enough space for an "X.Y.Z" string
        let bufferSize = 32
        var outputBuffer = [Int8](repeating: 0, count: bufferSize)
        
        // 2. Call the global ANSI C function safely without naming conflicts
        let statusCode = getVersion(&outputBuffer, bufferSize)
        
        // 3. Evaluate the status code matching the C macro logic
        switch statusCode {
        case 0: // VERSION_SUCCESS
            if let versionSwiftString = String(cString: outputBuffer, encoding: .utf8) {
                return versionSwiftString
            } else {
                return "Error: Could not decode version string from C."
            }
        case -1: // VERSION_ERR_INSUFFICIENT_BUF
            return "Error from C: Insufficient buffer size."
        default:
            return "Unknown error in native getVersion component."
        }
    }
}
```
