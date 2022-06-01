// swift-tools-version:5.5
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
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", .exactItem("0.34.0")),
    .package(url: "https://github.com/pointfreeco/composable-core-location", .exact("0.1.0")),
    .package(
      name: "SnapshotTesting",
      url: "https://github.com/pointfreeco/swift-snapshot-testing.git",
      .upToNextMajor(from: "1.8.2")
    ),
    .package(url: "https://github.com/pointfreeco/swift-custom-dump", .upToNextMajor(from: "0.3.0")),
    .package(name: "KeychainSwift", url: "https://github.com/evgenyneu/keychain-swift.git", .upToNextMajor(from: "19.0.0"))
  ],
  targets: [
    .target(
      name: "ApiClient",
      dependencies:[
        "Helper",
        "KeychainClient",
        "SharedModels",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
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
        .product(
          name: "ComposableArchitecture",
          package: "swift-composable-architecture"
        ),
      ]
    ),
    .target(
      name: "ContactFeature",
      dependencies:[
        "L10n",
        "SharedModels",
        "Styleguide",
        .product(
          name: "ComposableArchitecture",
          package: "swift-composable-architecture"
        ),
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
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
      ],
      resources: [.process("Resources")]
    ),
    .target(
      name: "FileClient",
      dependencies: [
        "Helper",
        "SharedModels",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
      ]
    ),
    .target(
      name: "Helper",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
      ]
    ),
    .target(
      name: "ImagesFeature",
      dependencies: [
        "Helper",
        "L10n",
        "PhotoLibraryAccessClient",
        "SharedModels",
        "Styleguide",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
      ]
    ),
    .target(
      name: "KeychainClient",
      dependencies: [
        .product(name: "KeychainSwift", package: "KeychainSwift"),
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
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
        .product(
          name: "ComposableArchitecture",
          package: "swift-composable-architecture"
        ),
        .product(
          name: "ComposableCoreLocation",
          package: "composable-core-location"
        )
      ]
    ),
    .target(
      name: "MailFeature",
      dependencies: [
        "L10n",
        "SharedModels",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
      ]
    ),
    .target(
      name: "PathMonitorClient",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
      ]
    ),
    .target(
      name: "PhotoLibraryAccessClient",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
      ]
    ),
    .target(
      name: "PlacesServiceClient",
      dependencies: [
        "SharedModels",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
      ]
    ),
    .target(
      name: "RegulatoryOfficeMapper",
      dependencies: [
        "SharedModels",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
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
        "ImagesFeature",
        "L10n",
        "LocationFeature",
        "MailFeature",
        "PathMonitorClient",
        "PlacesServiceClient",
        "RegulatoryOfficeMapper",
        "SharedModels",
        .product(
          name: "ComposableCoreLocation",
          package: "composable-core-location"
        ),
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
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
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
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
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
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
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
      ],
      exclude: [
        "AppFeatureTests.swift.plist"
      ]
    ),
    .testTarget(
      name: "ContactFeatureTests",
      dependencies: [
        "ContactFeature",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
      ]
    ),
    .testTarget(
      name: "DescriptionFeatureTests",
      dependencies: [
        "DescriptionFeature",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
      ]
    ),
    .testTarget(
      name: "ImagesFeatureTests",
      dependencies: [
        "ImagesFeature",
        "L10n",
        "PhotoLibraryAccessClient",
        "SharedModels",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(
          name: "ComposableCoreLocation",
          package: "composable-core-location"
        )
      ]
    ),
    .testTarget(
      name: "LocationFeatureTests",
      dependencies: [
        "LocationFeature",
        "PlacesServiceClient",
        "SharedModels",
        "UIApplicationClient",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(
          name: "ComposableCoreLocation",
          package: "composable-core-location"
        )
      ]
    ),
    .testTarget(
      name: "MailFeatureTests",
      dependencies: [
        "MailFeature",
        "SharedModels",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
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
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "CustomDump", package: "swift-custom-dump")
      ]
    ),
    .testTarget(
      name: "SettingsFeatureTests",
      dependencies: [
        "SharedModels",
        "SettingsFeature",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
      ]
    ),
    .testTarget(
      name: "AppStoreConnectScreenshots",
      dependencies: [
        "AppFeature",
        "DescriptionFeature",
        "ReportFeature",
        .product(name: "SnapshotTesting", package: "SnapshotTesting")
      ],
      exclude: [
        "__Snapshots__"
      ],
      resources: [.process("Resources")]
    )
  ]
)
