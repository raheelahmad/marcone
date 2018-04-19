// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "marcone",
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0-rc.2"),
        .package(url: "https://github.com/vapor/postgresql", from: "1.0.0-rc.2.0.2"),
        .package(url: "https://github.com/drmohundro/SWXMLHash.git", from: "4.6.0"),
    ],
    targets: [
        .target(
            name: "marconeLib",
            dependencies: ["Vapor",  "PostgreSQL", "SWXMLHash",]),
        Target.target(name: "marcone", dependencies: ["marconeLib"]),
        Target.testTarget(name: "marconeTests",
                          dependencies: ["marconeLib", "SWXMLHash", "PostgreSQL"])

    ]
)
