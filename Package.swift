// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "Project4",
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),

        // 🔵 Swift ORM (queries, models, relations, etc) built on MySQL.
        .package(url: "https://github.com/vapor/fluent-mysql.git", from: "3.0.0"),

        .package(url: "https://github.com/vapor/leaf.git", from: "3.0.0"),
        .package(url: "https://github.com/vapor/auth.git", from: "2.0.1"),
        .package(url: "https://github.com/SwiftOnTheServer/SwiftDotEnv.git", from: "2.0.1"),
        .package(url: "https://github.com/MatthewYork/DateTools.git", from: "4.0.0")
    ],
    targets: [
        .target(name: "App", dependencies: ["Leaf", "FluentMySQL", "Vapor", "Authentication", "SwiftDotEnv", "DateToolsSwift"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)

