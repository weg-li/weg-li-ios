// Created for weg-li in 2021.

import SwiftUI
import UIKit.UIColor

public extension Color {
  static var wegliBlue: Self { Self(UIColor.wegliBlue) }
  static var gitHubBannerForeground: Self { Self(UIColor.gitHubBannerForeground)
  }

  static var gitHubBannerBackground: Self {
    Self(UIColor.gitHubBannerBackground)
  }
}

// MARK: Helper

extension UIColor {
  static var wegliBlue: Self { Self.hex(0x21709b) }
  static var gitHubBannerForeground: Self { Self.hex(0x40c8dd) }
  static var gitHubBannerBackground: Self { Self.hex(0x483c46) }
}

public extension UIColor {
  static func hex(_ hex: UInt, alpha: CGFloat = 1) -> Self {
    Self(
      red: CGFloat((hex & 0xff0000) >> 16) / 255,
      green: CGFloat((hex & 0x00ff00) >> 8) / 255,
      blue: CGFloat(hex & 0x0000ff) / 255,
      alpha: alpha
    )
  }
}
