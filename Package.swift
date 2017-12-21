// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "XML",
    products: [
        .library(name: "XML", targets: ["XML"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/swift-stack/test.git",
            .branch("master"))
    ],
    targets: [
        .target(
            name: "XML",
            dependencies: []),
        .testTarget(
            name: "XMLTests",
            dependencies: ["XML", "Test"]),
    ]
)
