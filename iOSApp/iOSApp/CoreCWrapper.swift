//
//  ValidadorComponente.swift
//  iOSApp
//
//  Created by JAVIER CALATRAVA LLAVERIA on 4/6/26.
//
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

