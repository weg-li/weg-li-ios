// Created for weg-li in 2021.

import Foundation
import L10n

public enum LocationOption: String, CaseIterable, Codable {
  case fromPhotos
  case currentLocation
  case manual
  
  public var title: String {
    switch self {
    case .fromPhotos: return L10n.Location.PickerCopy.fromPhotos
    case .currentLocation: return L10n.Location.PickerCopy.currentLocation
    case .manual: return L10n.Location.PickerCopy.manual
    }
  }
}
