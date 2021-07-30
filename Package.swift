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
            path: "Source"
        )
    ]
)
