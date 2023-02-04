// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "WegliKit",
  defaultLocalization: "de",
  platforms: [
    .iOS(.v16)
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
    .package(url: "https://github.com/pointfreeco/xctest-dynamic-overlay", from: "0.2.0"),
    .package(url: "https://github.com/pointfreeco/swiftui-navigation.git", from: "0.4.0"),
    .package(url: "https://github.com/onevcat/Kingfisher.git", from: "7.5.0"),
  ],
  targets: [
    .target(
      name: "ApiClient",
      dependencies: [
        .helper,
        .keychainClient,
        .models,
        .tca,
        .testOverlay
      ]
    ),
    .target(
      name: "AppFeature",
      dependencies: [
        .apiClient,
        .fileClient,
        .keychainClient,
        .l10n,
        "ReportFeature",
        "SettingsFeature",
        .models,
        .styleguide,
        .tca,
        .navigation
      ]
    ),
    .target(
      name: "CameraAccessClient",
      dependencies: [
        .tca,
        .testOverlay
      ]
    ),
    .target(
      name: "ContactFeature",
      dependencies: [
        .fileClient,
        .l10n,
        .models,
        .styleguide,
        .tca
      ]
    ),
    .target(
      name: "DescriptionFeature",
      dependencies: [
        .fileClient,
        .helper,
        .l10n,
        .models,
        .styleguide,
        .tca
      ],
      resources: [.process("Resources")]
    ),
    .target(
      name: "FileClient",
      dependencies: [
        .helper,
        .models,
        .tca,
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
        .helper,
        .l10n,
        "PhotoLibraryAccessClient",
        .models,
        .styleguide,
        .tca,
        .navigation,
        .product(name: "Kingfisher", package: "Kingfisher")
      ]
    ),
    .target(
      name: "ImagesUploadClient",
      dependencies: [
        .apiClient,
        .models,
        .tca,
        .testOverlay
      ]
    ),
    .target(
      name: "KeychainClient",
      dependencies: [
        .product(name: "KeychainSwift", package: "keychain-swift"),
        .tca,
        .testOverlay
      ]
    ),
    .target(
      name: "L10n"
    ),
    .target(
      name: "LocationFeature",
      dependencies: [
        .l10n,
        .helper,
        .placesServiceClient,
        .models,
        .styleguide,
        .applicationClient,
        .tca,
        .locationClient
      ]
    ),
    .target(
      name: "MailFeature",
      dependencies: [
        .l10n,
        .models,
        .tca
      ]
    ),
    .target(
      name: "PathMonitorClient",
      dependencies: [
        .tca,
        .testOverlay
      ]
    ),
    .target(
      name: "PhotoLibraryAccessClient",
      dependencies: [
        .tca,
        .testOverlay
      ]
    ),
    .target(
      name: "PlacesServiceClient",
      dependencies: [
        .models,
        .tca,
        .testOverlay
      ]
    ),
    .target(
      name: "RegulatoryOfficeMapper",
      dependencies: [
        .models,
        .tca,
        .testOverlay
      ],
      resources: [.process("Resources")]
    ),
    .target(
      name: "ReportFeature",
      dependencies: [
        .apiClient,
        "ContactFeature",
        "DescriptionFeature",
        .fileClient,
        .helper,
        "ImagesUploadClient",
        "ImagesFeature",
        .l10n,
        "LocationFeature",
        "MailFeature",
        "PathMonitorClient",
        .placesServiceClient,
        "RegulatoryOfficeMapper",
        .models,
        .locationClient,
        .tca,
        .testOverlay
      ]
    ),
    .target(
      name: "SettingsFeature",
      dependencies: [
        .apiClient,
        "ContactFeature",
        .helper,
        .keychainClient,
        .l10n,
        .models,
        .styleguide,
        .applicationClient,
        .tca,
        .navigation
      ]
    ),
    .target(
      name: "SharedModels",
      dependencies: [
        .helper,
        .l10n
      ]
    ),
    .target(
      name: "Styleguide",
      dependencies: [
        .l10n,
        .helper
      ],
      resources: [.process("Resources")]
    ),
    .target(
      name: "UIApplicationClient",
      dependencies: [
        .tca,
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
        .models,
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
        .fileClient,
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
        .l10n,
        "PhotoLibraryAccessClient",
        .models,
        .tca,
        .locationClient
      ]
    ),
    .testTarget(
      name: "LocationFeatureTests",
      dependencies: [
        "LocationFeature",
        .placesServiceClient,
        .models,
        .applicationClient,
        .tca,
        .locationClient
      ]
    ),
    .testTarget(
      name: "MailFeatureTests",
      dependencies: [
        "MailFeature",
        .models,
        .tca,
        .product(name: "CustomDump", package: "swift-custom-dump")
      ]
    ),
    .testTarget(
      name: "ReportFeatureTests",
      dependencies: [
        "ImagesFeature",
        "LocationFeature",
        .placesServiceClient,
        "ReportFeature",
        .models,
        .tca,
        .product(name: "CustomDump", package: "swift-custom-dump")
      ]
    ),
    .testTarget(
      name: "SettingsFeatureTests",
      dependencies: [
        .models,
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
  static let apiClient = byName(name: "ApiClient")
  static let models = byName(name: "SharedModels")
  static let helper = byName(name: "Helper")
  static let fileClient = byName(name: "FileClient")
  static let keychainClient = byName(name: "KeychainClient")
  static let l10n = byName(name: "L10n")
  static let applicationClient = byName(name: "UIApplicationClient")
  static let styleguide = byName(name: "Styleguide")
  static let placesServiceClient = byName(name: "PlacesServiceClient")
  
  static let tca = product(name: "ComposableArchitecture", package: "swift-composable-architecture")
  static let locationClient = product(name: "ComposableCoreLocation", package: "composable-core-location")
  static let testOverlay = product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay")
  static let navigation = product(name: "SwiftUINavigation", package: "swiftui-navigation")
  static let customDump = product(name: "CustomDump", package: "swift-custom-dump")
}
