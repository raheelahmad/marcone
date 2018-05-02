// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "marcone",
    dependencies: [
	.package(url: "https://github.com/vapor/vapor.git", from: "3.0.0-rc.2.8.1"),
    .package(url: "https://github.com/vapor/postgresql", from: "1.0.0-rc.2.1"),
    .package(url: "https://github.com/drmohundro/SWXMLHash.git", from: "4.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target( name: "App", dependencies: ["Vapor", "PostgreSQL", "SWXMLHash"]),
        .target( name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App", "SWXMLHash"])
    ]
)
