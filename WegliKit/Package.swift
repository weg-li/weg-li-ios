// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "WegliKit",
  defaultLocalization: "de",
  platforms: [
    .iOS(.v15)
  ],
  products: [
    .library(
      name: "AppFeature",
      targets: ["AppFeature"]
    ),
    .library(
      name: "ContactFeature",
      targets: ["ContactFeature"]
    ),
    .library(
      name: "DescriptionFeature",
      targets: ["DescriptionFeature"]
    ),
    .library(
      name: "ImagesFeature",
      targets: ["ImagesFeature"]
    ),
    .library(
      name: "LocationFeature",
      targets: ["LocationFeature"]
    ),
    .library(
      name: "MailFeature",
      targets: ["MailFeature"]
    ),
    .library(
      name: "ReportFeature",
      targets: ["ReportFeature"]
    ),
    .library(
      name: "SettingsFeature",
      targets: ["SettingsFeature"]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", .upToNextMajor(from: "0.34.0")),
    .package(url: "https://github.com/pointfreeco/composable-core-location", exact: "0.1.0"),
    .package(url: "https://github.com/pointfreeco/swift-snapshot-testing.git", .upToNextMajor(from: "1.10.0")),
    .package(url: "https://github.com/pointfreeco/swift-custom-dump", .upToNextMajor(from: "0.3.0")),
    .package(url: "https://github.com/evgenyneu/keychain-swift.git", .upToNextMajor(from: "19.0.0")),
    .package(url: "https://github.com/pointfreeco/xctest-dynamic-overlay", from: "0.2.0")
  ],
  targets: [
    .target(
      name: "ApiClient",
      dependencies: [
        "Helper",
        "KeychainClient",
        "SharedModels",
        .product(name: "Dependencies", package: "swift-composable-architecture"),
        .testOverlay
      ]
    ),
    .target(
      name: "AppFeature",
      dependencies: [
        "ApiClient",
        "FileClient",
        "KeychainClient",
        "L10n",
        "ReportFeature",
        "SettingsFeature",
        "SharedModels",
        "Styleguide",
        .tca
      ]
    ),
    .target(
      name: "CameraAccessClient",
      dependencies: [
        .product(name: "Dependencies", package: "swift-composable-architecture"),
        .testOverlay
      ]
    ),
    .target(
      name: "ContactFeature",
      dependencies: [
        "L10n",
        "SharedModels",
        "Styleguide",
        .tca
      ]
    ),
    .target(
      name: "DescriptionFeature",
      dependencies: [
        "FileClient",
        "Helper",
        "L10n",
        "SharedModels",
        "Styleguide",
        .tca
      ],
      resources: [.process("Resources")]
    ),
    .target(
      name: "FileClient",
      dependencies: [
        "Helper",
        "SharedModels",
        .product(name: "Dependencies", package: "swift-composable-architecture"),
        .testOverlay
      ]
    ),
    .target(
      name: "Helper",
      dependencies: [
        .tca
      ]
    ),
    .target(
      name: "ImagesFeature",
      dependencies: [
        "CameraAccessClient",
        "Helper",
        "L10n",
        "PhotoLibraryAccessClient",
        "SharedModels",
        "Styleguide",
        .tca
      ]
    ),
    .target(
      name: "ImagesUploadClient",
      dependencies: [
        "ApiClient",
        "SharedModels",
        .product(name: "Dependencies", package: "swift-composable-architecture"),
        .testOverlay
      ]
    ),
    .target(
      name: "KeychainClient",
      dependencies: [
        .product(name: "KeychainSwift", package: "keychain-swift"),
        .product(name: "Dependencies", package: "swift-composable-architecture"),
        .testOverlay
      ]
    ),
    .target(
      name: "L10n"
    ),
    .target(
      name: "LocationFeature",
      dependencies: [
        "L10n",
        "Helper",
        "PlacesServiceClient",
        "SharedModels",
        "Styleguide",
        "UIApplicationClient",
        .tca,
        .locationClient
      ]
    ),
    .target(
      name: "MailFeature",
      dependencies: [
        "L10n",
        "SharedModels",
        .tca
      ]
    ),
    .target(
      name: "PathMonitorClient",
      dependencies: [
        .product(name: "Dependencies", package: "swift-composable-architecture"),
        .testOverlay
      ]
    ),
    .target(
      name: "PhotoLibraryAccessClient",
      dependencies: [
        .product(name: "Dependencies", package: "swift-composable-architecture"),
        .testOverlay
      ]
    ),
    .target(
      name: "PlacesServiceClient",
      dependencies: [
        "SharedModels",
        .product(name: "Dependencies", package: "swift-composable-architecture"),
        .testOverlay
      ]
    ),
    .target(
      name: "RegulatoryOfficeMapper",
      dependencies: [
        "SharedModels",
        .product(name: "Dependencies", package: "swift-composable-architecture"),
        .testOverlay
      ],
      resources: [.process("Resources")]
    ),
    .target(
      name: "ReportFeature",
      dependencies: [
        "ApiClient",
        "ContactFeature",
        "DescriptionFeature",
        "FileClient",
        "Helper",
        "ImagesUploadClient",
        "ImagesFeature",
        "L10n",
        "LocationFeature",
        "MailFeature",
        "PathMonitorClient",
        "PlacesServiceClient",
        "RegulatoryOfficeMapper",
        "SharedModels",
        .locationClient,
        .tca
      ]
    ),
    .target(
      name: "SettingsFeature",
      dependencies: [
        "ApiClient",
        "ContactFeature",
        "Helper",
        "KeychainClient",
        "L10n",
        "SharedModels",
        "Styleguide",
        "UIApplicationClient",
        .tca
      ]
    ),
    .target(
      name: "SharedModels",
      dependencies: [
        "Helper",
        "L10n"
      ]
    ),
    .target(
      name: "Styleguide",
      dependencies: [
        "L10n",
        "Helper"
      ],
      resources: [.process("Resources")]
    ),
    .target(
      name: "UIApplicationClient",
      dependencies: [
        .product(name: "Dependencies", package: "swift-composable-architecture"),
        .testOverlay
      ]
    )
  ]
)

// MARK: - Test Targets

package.targets.append(
  contentsOf: [
    .testTarget(
      name: "AppFeatureTests",
      dependencies: [
        "AppFeature",
        "ContactFeature",
        "DescriptionFeature",
        "ImagesFeature",
        "ReportFeature",
        "SharedModels",
        .tca
      ],
      exclude: [
        "AppFeatureTests.swift.plist"
      ]
    ),
    .testTarget(
      name: "ContactFeatureTests",
      dependencies: [
        "ContactFeature",
        .tca
      ]
    ),
    .testTarget(
      name: "DescriptionFeatureTests",
      dependencies: [
        "DescriptionFeature",
        .tca
      ]
    ),
    .testTarget(
      name: "ImagesFeatureTests",
      dependencies: [
        "CameraAccessClient",
        "ImagesFeature",
        "L10n",
        "PhotoLibraryAccessClient",
        "SharedModels",
        .tca,
        .locationClient
      ]
    ),
    .testTarget(
      name: "LocationFeatureTests",
      dependencies: [
        "LocationFeature",
        "PlacesServiceClient",
        "SharedModels",
        "UIApplicationClient",
        .tca,
        .locationClient
      ]
    ),
    .testTarget(
      name: "MailFeatureTests",
      dependencies: [
        "MailFeature",
        "SharedModels",
        .tca,
        .product(name: "CustomDump", package: "swift-custom-dump")
      ]
    ),
    .testTarget(
      name: "ReportFeatureTests",
      dependencies: [
        "ImagesFeature",
        "LocationFeature",
        "PlacesServiceClient",
        "ReportFeature",
        "SharedModels",
        .tca,
        .product(name: "CustomDump", package: "swift-custom-dump")
      ]
    ),
    .testTarget(
      name: "SettingsFeatureTests",
      dependencies: [
        "SharedModels",
        "SettingsFeature",
        .tca
      ]
    ),
    .testTarget(
      name: "AppStoreConnectScreenshots",
      dependencies: [
        "AppFeature",
        "DescriptionFeature",
        "ReportFeature",
        .product(name: "SnapshotTesting", package: "swift-snapshot-testing")
      ],
      exclude: [
        "__Snapshots__"
      ],
      resources: [.process("Resources")]
    )
  ]
)


extension Target.Dependency {
  static let tca = product(name: "ComposableArchitecture", package: "swift-composable-architecture")
  static let locationClient = product(name: "ComposableCoreLocation", package: "composable-core-location")
//  static let dependencies = product(name: "Dependencies", package: "swift-composable-architecture")
  static let testOverlay = product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay")
}
