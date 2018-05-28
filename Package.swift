// swift-tools-version:4.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription


let package = Package(
    name: "swift-server-app",
    products: [
        .library(name: "SwiftServerApp", targets: ["SwiftServerApp"]),
    ],
    dependencies: [
        .package(url: "https://github.com/PerfectlySoft/Perfect-HTTPServer.git", from: "3.0.15"),
        .package(url: "https://github.com/Molbie/swift-PostgreSQL.git", from: "1.0.0"),
        .package(url: "https://github.com/Molbie/Outlaw.git", from: "2.0.2"),
    ],
    targets: [
        .target(name: "SwiftServerApp", dependencies: ["PerfectHTTPServer", "Outlaw", "SwiftPostgreSQL"])
    ]
)
