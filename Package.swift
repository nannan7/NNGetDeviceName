// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "NNGetDeviceName",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "NNGetDeviceName",
            targets: ["NNGetDeviceName"]
        )
    ],
    targets: [
        .target(
            name: "NNGetDeviceName"
        ),
        .testTarget(
            name: "NNGetDeviceNameTests",
            dependencies: ["NNGetDeviceName"]
        )
    ]
)
