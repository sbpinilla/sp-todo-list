// swift-tools-version: 6.0
import PackageDescription

// THROWAWAY spike package (HU1). Replaced by the real skeleton in HU2.
let package = Package(
    name: "sp-todo-list",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(name: "Spike", path: "Sources/Spike")
    ]
)
