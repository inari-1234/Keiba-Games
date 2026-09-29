// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "KeibaCore",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [.library(name: "KeibaCore", targets: ["KeibaCore"])],
    targets: [
        .target(name: "KeibaCore"),
        .testTarget(name: "KeibaCoreTests", dependencies: ["KeibaCore"]),
    ]
)
