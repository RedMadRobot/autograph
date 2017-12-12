// swift-tools-version:4.0


import PackageDescription


let package = Package(
    name: "Autograph",
    products: [
        Product.library(
            name: "Autograph",
            targets: ["Autograph"]
        )
    ],
    dependencies: [
        Package.Dependency.package(
            url: "https://github.com/RedMadRobot/synopsis",
            from: "1.1.1"
        )
    ],
    targets: [
        Target.target(
            name: "Autograph",
            dependencies: ["Synopsis"]
        ),
        Target.testTarget(
            name: "AutographTests",
            dependencies: ["Autograph"]
        ),
    ]
)
