[![CI](https://github.com/weg-li/weg-li-ios/actions/workflows/ci.yml/badge.svg)](https://github.com/weg-li/weg-li-ios/actions/workflows/ci.yml)
<a title="Join TestFlight" target="_blank" href="https://testflight.apple.com/join/3SCoUsnL"><img src="https://img.shields.io/badge/Join-TestFlight-blue.svg" alt="Join TestFlight" />

# weg-li iOS App

Use [`weg-li`](https://www.weg-li.de) app to easily report wrong parking cars.  

### Project Setup

The App uses Apple's `Combine.framework` for operation scheduling. The UI-Layer is built with [`The Composable Architecture`](https://github.com/pointfreeco/swift-composable-architecture) and `SwiftUI`.
Minimum platform requirements are: iOS 15.0

### Modularization

The application is built in a hyper-modularized style. This allows to work on features without building the entire application, which improves compile times and SwiftUI preview stability. Every feature is its own target which makes it also possible to build mini-apps to run in the simulator for preview.

### Getting Started

#### Setup

* Install latest Xcode version via macOS App Store

1. Grab the code:
    ```sh
    git clone https://github.com/weg-li/weg-li-ios.git
    cd weg-li
    ```
2. Open the Xcode project `weg-li.xcodeproj`.
3. To run the client locally, select the `weg-li` target in Xcode and run (`⌘R`).

#### Dependencies

The project is using some tools like fastlane, swiftlint and others.
To install them execute 

```shell
make dependencies
```
in the root folder.


### Strings

When you feature needs new Strings please add them to the `Localizable.strings` file (en and de are the same atm) and after that execute `make swiftgen` to run code generation. You can then use them from the `L10n` enum.


### 🎨 Designs

* [sketch cloud](https://www.sketch.com/s/dfb7001d-366f-4977-b204-34917d9dec71)


### How to contribute

In general, we follow the "fork-and-pull" Git workflow.

1.  **Fork** the repo on GitHub
2.  **Clone** the project to your own machine
3.  **Commit** changes to your own branch.
4.  **Push** your work back up to your fork
5.  Submit a **Pull request** so that we can review your changes

NOTES: 
- Be sure to merge the latest from "upstream" before making a pull request!
