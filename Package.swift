// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "RaiderReSell",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .executable(
            name: "RaiderReSell",
            targets: ["RaiderReSell"]),
    ],
    dependencies: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "10.0.0"),
        .package(url: "https://github.com/google/generative-ai-swift", from: "0.4.0"),
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.8.0"),
        .package(url: "https://github.com/SDWebImage/SDWebImageSwiftUI.git", from: "2.2.0"),
        .package(url: "https://github.com/MessageKit/MessageKit.git", from: "4.2.0")
    ],
    targets: [
        .executableTarget(
            name: "RaiderReSell",
            dependencies: [
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
                .product(name: "FirebaseStorage", package: "firebase-ios-sdk"),
                .product(name: "FirebaseMessaging", package: "firebase-ios-sdk"),
                .product(name: "GoogleGenerativeAI", package: "generative-ai-swift"),
                "Alamofire",
                .product(name: "SDWebImageSwiftUI", package: "SDWebImageSwiftUI"),
                "MessageKit"
            ],
            path: "RaiderReSell"),
        .testTarget(
            name: "RaiderReSeillTests",
            dependencies: ["RaiderReSell"],
            path: "Tests"),
    ]
) 