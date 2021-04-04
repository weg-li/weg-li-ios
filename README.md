[![CI](https://github.com/weg-li/weg-li-ios/actions/workflows/ci.yml/badge.svg)](https://github.com/weg-li/weg-li-ios/actions/workflows/ci.yml)
# 🚲 weg-li iOS App

With [weg-li](https://www.weg-li.de) you can easily report wrong parking cars.  

## Setup

* Install latest Xcode version via macOS App Store

### Dependencies

The project is using some tools like fastlane, swiftlint and others.
To install them execute 

```shell
make dependencies
```
in the root folder.

## Project


#### Strings

When you feature needs new Strings please add them to the `Localizable.strings` file (en and de are the same atm) and after that execute `make swiftgen` to run code generation. You can then use them from the `L10n` enum.


## 🎨 Designs

* [sketch cloud](https://www.sketch.com/s/dfb7001d-366f-4977-b204-34917d9dec71)
