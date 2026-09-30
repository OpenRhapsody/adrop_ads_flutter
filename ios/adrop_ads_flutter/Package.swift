// swift-tools-version: 5.9
// Manifest for Flutter's Swift Package Manager integration.
// Coexists with CocoaPods (adrop_ads_flutter.podspec); this one is used when the app enables SPM.
import PackageDescription

let package = Package(
    name: "adrop_ads_flutter",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        // The library name uses hyphens. SwiftPM uses the library name as the CFBundleIdentifier when linking
        // dynamically, and bundle IDs cannot contain underscores, so the flutter tool also refers to it as
        // `plugin_name.replaceAll('_', '-')`.
        .library(name: "adrop-ads-flutter", targets: ["adrop_ads_flutter"])
    ],
    dependencies: [
        // Distribution repo for the same native SDK (AdropAds.xcframework) as CocoaPods' `adrop-ads`.
        // Always bump this version range together with `s.dependency 'adrop-ads', ...` in adrop_ads_flutter.podspec.
        .package(url: "https://github.com/OpenRhapsody/adrop-ads-pod.git", "1.14.0" ..< "1.15.0")
    ],
    targets: [
        .target(
            name: "adrop_ads_flutter",
            dependencies: [
                .product(name: "AdropAds", package: "adrop-ads-pod")
            ]
        )
    ]
)
