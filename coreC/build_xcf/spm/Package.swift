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
