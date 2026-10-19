// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "sp-todo-list",
    platforms: [.macOS(.v14)],
    targets: [
        .target(name: "TodoDomain"),
        .target(name: "TodoApplication", dependencies: ["TodoDomain"]),
        .target(name: "TodoInfrastructure", dependencies: ["TodoApplication"]),
        .target(name: "TodoUI", dependencies: ["TodoApplication"]),
        .executableTarget(
            name: "SpTodoList",
            dependencies: ["TodoDomain", "TodoApplication", "TodoInfrastructure", "TodoUI"]
        ),
        .testTarget(name: "TodoDomainTests", dependencies: ["TodoDomain"]),
        .testTarget(name: "TodoApplicationTests", dependencies: ["TodoApplication"]),
        .testTarget(name: "TodoInfrastructureTests", dependencies: ["TodoInfrastructure"]),
        .testTarget(name: "TodoUITests", dependencies: ["TodoUI", "TodoDomain", "TodoApplication"]),
    ]
)
