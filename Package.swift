// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TimeIndependentDates",
    platforms: [.macOS(.v14)],
    products: [
        .library(
            name: "TimeIndependentDates",
            targets: ["TimeIndependentDates"]),
    ],
    targets: [
        .target(
            name: "TimeIndependentDates"),
        .testTarget(
            name: "TimeIndependentDatesTests",
            dependencies: ["TimeIndependentDates"]),
    ]
)
