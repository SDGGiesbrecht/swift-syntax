// swift-tools-version:5.5

import PackageDescription
import Foundation

/// If we are in a controlled CI environment, we can use internal compiler flags
/// to speed up the build or improve it.
let swiftSyntaxSwiftSettings: [SwiftSetting]
if ProcessInfo.processInfo.environment["SWIFT_BUILD_SCRIPT_ENVIRONMENT"] != nil {
  let groupFile = URL(fileURLWithPath: #file)
    .deletingLastPathComponent()
    .appendingPathComponent("utils")
    .appendingPathComponent("group.json")
  swiftSyntaxSwiftSettings = [
    .define("SWIFTSYNTAX_ENABLE_ASSERTIONS"),
    .unsafeFlags([
      "-Xfrontend", "-group-info-path",
      "-Xfrontend", groupFile.path,
      // Enforcing exclusivity increases compile time of release builds by 2 minutes.
      // Disable it when we're in a controlled CI environment.
      "-enforce-exclusivity=unchecked",
    ]),
  ]
} else {
  swiftSyntaxSwiftSettings = []
}

let package = Package(
  name: "SwiftSyntax",
  platforms: [
    .macOS(.v10_15),
    .iOS(.v13),
    .tvOS(.v13),
    .watchOS(.v6),
    .macCatalyst(.v13),
  ],
  products: [
    .library(name: "IDEUtils", type: .static, targets: ["IDEUtils"]),
    .library(name: "SwiftDiagnostics", type: .static, targets: ["SwiftDiagnostics"]),
    .library(name: "SwiftOperators", type: .static, targets: ["SwiftOperators"]),
    .library(name: "SwiftParser", type: .static, targets: ["SwiftParser"]),
    .library(name: "SwiftParserDiagnostics", type: .static, targets: ["SwiftParserDiagnostics"]),
    .library(name: "SwiftSyntax", type: .static, targets: ["SwiftSyntax"]),
    .library(name: "SwiftSyntaxParser", type: .static, targets: ["SwiftSyntaxParser"]),
    .library(name: "SwiftSyntaxBuilder", type: .static, targets: ["SwiftSyntaxBuilder"]),
    .library(name: "SwiftSyntaxMacros", type: .static, targets: ["SwiftSyntaxMacros"]),
    .library(name: "SwiftCompilerPlugin", type: .static, targets: ["SwiftCompilerPlugin"]),
    .library(name: "SwiftCompilerPluginMessageHandling", type: .static, targets: ["SwiftCompilerPluginMessageHandling"]),
    .library(name: "SwiftRefactor", type: .static, targets: ["SwiftRefactor"]),
  ],
  targets: [
    .target(name: "_InstructionCounter"),
    .target(
      name: "SwiftBasicFormat",
      dependencies: ["SwiftSyntax"],
      exclude: [
        "CMakeLists.txt"
      ]
    ),
    .target(
      name: "SwiftDiagnostics",
      dependencies: ["SwiftSyntax"],
      exclude: [
        "CMakeLists.txt"
      ]
    ),
    .target(
      name: "SwiftSyntax",
      dependencies: [],
      exclude: [
        "CMakeLists.txt"
      ],
      swiftSettings: swiftSyntaxSwiftSettings
    ),
    .target(
      name: "SwiftSyntaxBuilder",
      dependencies: ["SwiftBasicFormat", "SwiftSyntax", "SwiftParser", "SwiftParserDiagnostics"],
      exclude: [
        "CMakeLists.txt"
      ]
    ),
    .target(
      name: "SwiftSyntaxParser",
      dependencies: ["SwiftSyntax", "SwiftParser"]
    ),
    .target(
      name: "_SwiftSyntaxTestSupport",
      dependencies: ["SwiftBasicFormat", "SwiftSyntax", "SwiftSyntaxBuilder"]
    ),
    .target(
      name: "IDEUtils",
      dependencies: ["SwiftSyntax"],
      exclude: [
        "CMakeLists.txt"
      ]
    ),
    .target(
      name: "SwiftParser",
      dependencies: ["SwiftSyntax"],
      exclude: [
        "CMakeLists.txt",
        "README.md",
      ]
    ),
    .target(
      name: "SwiftParserDiagnostics",
      dependencies: ["SwiftBasicFormat", "SwiftDiagnostics", "SwiftParser", "SwiftSyntax"],
      exclude: [
        "CMakeLists.txt"
      ]
    ),
    .target(
      name: "SwiftOperators",
      dependencies: ["SwiftSyntax", "SwiftParser", "SwiftDiagnostics"],
      exclude: [
        "CMakeLists.txt"
      ]
    ),
    .target(
      name: "SwiftSyntaxMacros",
      dependencies: [
        "SwiftSyntax", "SwiftSyntaxBuilder", "SwiftParser", "SwiftDiagnostics",
      ],
      exclude: [
        "CMakeLists.txt"
      ]
    ),
    .target(
      name: "SwiftCompilerPlugin",
      dependencies: [
        "SwiftCompilerPluginMessageHandling", "SwiftSyntaxMacros",
      ]
    ),
    .target(
      name: "SwiftCompilerPluginMessageHandling",
      dependencies: [
        "SwiftSyntax", "SwiftParser", "SwiftDiagnostics", "SwiftSyntaxMacros", "SwiftOperators",
      ],
      exclude: [
        "CMakeLists.txt"
      ]
    ),
    .target(
      name: "SwiftRefactor",
      dependencies: [
        "SwiftSyntax", "SwiftParser",
      ]
    ),
    .executableTarget(
      name: "lit-test-helper",
      dependencies: ["IDEUtils", "SwiftSyntax", "SwiftSyntaxParser"]
    ),
    .executableTarget(
      name: "swift-parser-cli",
      dependencies: [
        "_InstructionCounter", "SwiftDiagnostics", "SwiftSyntax", "SwiftParser", "SwiftParserDiagnostics", "SwiftOperators",
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
      ]
    ),
    .testTarget(name: "IDEUtilsTest", dependencies: ["_SwiftSyntaxTestSupport", "SwiftParser", "SwiftSyntax", "IDEUtils"]),
    .testTarget(
      name: "SwiftDiagnosticsTest",
      dependencies: ["_SwiftSyntaxTestSupport", "SwiftDiagnostics", "SwiftParser", "SwiftParserDiagnostics"]
    ),
    .testTarget(
      name: "SwiftSyntaxTest",
      dependencies: ["SwiftSyntax", "_SwiftSyntaxTestSupport"]
    ),
    .testTarget(
      name: "SwiftSyntaxBuilderTest",
      dependencies: ["_SwiftSyntaxTestSupport", "SwiftSyntaxBuilder"]
    ),
    .testTarget(
      name: "SwiftSyntaxParserTest",
      dependencies: ["SwiftSyntaxParser", "_SwiftSyntaxTestSupport"],
      exclude: ["Inputs"]
    ),
    .testTarget(
      name: "SwiftSyntaxMacrosTest",
      dependencies: [
        "SwiftDiagnostics", "SwiftOperators", "SwiftParser",
        "_SwiftSyntaxTestSupport", "SwiftSyntaxBuilder",
        "SwiftSyntaxMacros",
      ]
    ),
    .testTarget(
      name: "PerformanceTest",
      dependencies: ["IDEUtils", "SwiftSyntax", "SwiftSyntaxParser", "SwiftParser"],
      exclude: ["Inputs"]
    ),
    .testTarget(
      name: "SwiftParserTest",
      dependencies: [
        "SwiftDiagnostics", "SwiftOperators", "SwiftParser",
        "_SwiftSyntaxTestSupport", "SwiftSyntaxBuilder",
      ]
    ),
    .testTarget(
      name: "SwiftParserDiagnosticsTest",
      dependencies: ["SwiftDiagnostics", "SwiftParserDiagnostics"]
    ),
    .testTarget(
      name: "SwiftOperatorsTest",
      dependencies: [
        "SwiftOperators", "_SwiftSyntaxTestSupport",
        "SwiftParser",
      ]
    ),
    .testTarget(
      name: "SwiftRefactorTest",
      dependencies: [
        "SwiftRefactor", "SwiftSyntaxBuilder", "_SwiftSyntaxTestSupport",
      ]
    ),
    .testTarget(
      name: "SwiftCompilerPluginTest",
      dependencies: [
        "SwiftCompilerPlugin"
      ]
    ),
  ]
)

if ProcessInfo.processInfo.environment["SWIFTCI_USE_LOCAL_DEPS"] == nil {
  // Building standalone.
  package.dependencies += [
    .package(url: "https://github.com/apple/swift-argument-parser.git", .upToNextMinor(from: "1.2.2"))
  ]
} else {
  package.dependencies += [
    .package(path: "../swift-argument-parser")
  ]
}
