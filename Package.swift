// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "marcone",
    dependencies: [
        .package(url: "https://github.com/vapor-community/postgresql.git", Package.Dependency.Requirement.exact(Version(2, 1, 1))),
        .package(url: "https://github.com/vapor/vapor", from: "2.4.4"),
        .package(url: "https://github.com/drmohundro/SWXMLHash.git", from: "4.0.0"),
    ],
    targets: [
        .target(
            name: "marcone",
            dependencies: ["Vapor", "SWXMLHash", "PostgreSQL"]),
    ]
)
