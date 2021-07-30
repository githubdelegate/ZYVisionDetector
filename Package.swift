// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "ZYVisionDetector",
    platforms: [.iOS(.v13)],
    products: [
        .library(name: "ZYVisionDetector", targets: ["ZYVisionDetector"])
    ],
    targets: [
        .target(
            name: "ZYVisionDetector",
            path: "Source",
            exclude: ["Pods", "ZYVisionDetector/", "Podfile", "sample.gif", "ZYVisionDetector.podspec"]
        )
    ]
)
