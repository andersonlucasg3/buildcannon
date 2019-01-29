// swift-tools-version:4.2
import PackageDescription

let package = Package.init(
    name: "buildcannon",
    products: [
        .executable(
            name: "buildcannon",
            targets: ["buildcannon"]
        )
    ],
    dependencies: [ ],
    targets: [
        .target(
            name: "buildcannon",
            dependencies: [],
            path: "buildcannon"),
        .testTarget(
            name: "buildcannonTest",
            dependencies: [],
            path: "buildcannonTest")
    ]
)

