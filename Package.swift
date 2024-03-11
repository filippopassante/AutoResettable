// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "AutoResettable",
    platforms: [.macOS(.v10_15), .iOS(.v12), .tvOS(.v13), .watchOS(.v6), .macCatalyst(.v13)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "AutoResettable",
            targets: ["AutoResettable"]
        ),
        .executable(
            name: "AutoResettableClient",
            targets: ["AutoResettableClient"]
        ),
    ],
    dependencies: [
        // Depend on the Swift 5.9 release of SwiftSyntax
        .package(url: "https://github.com/apple/swift-syntax.git", from: "509.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        // Macro implementation that performs the source transformation of a macro.
        .macro(
            name: "AutoResettableMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),

        // Library that exposes a macro as part of its API, which is used in client programs.
        .target(name: "AutoResettable", dependencies: ["AutoResettableMacros"]),

        // A client of the library, which is able to use the macro in its own code.
        .executableTarget(name: "AutoResettableClient", dependencies: ["AutoResettable"]),

        // A test target used to develop the macro implementation.
        .testTarget(
            name: "AutoResettableTests",
            dependencies: [
                "AutoResettableMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ]
        ),
    ]
)
