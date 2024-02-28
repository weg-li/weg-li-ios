// Created for weg-li in 2021.

import Foundation
import UIKit

public struct PickerImageResult: Hashable, Identifiable, Codable {
  public let id: String
  public var imageUrl: URL?
  public var coordinate: CoordinateRegion.Coordinate?
  public var creationDate: Date?
  public var image: Data?

  public init(
    id: String,
    imageUrl: URL? = nil,
    coordinate: CoordinateRegion.Coordinate? = nil,
    creationDate: Date? = nil
  ) {
    self.id = id
    self.imageUrl = imageUrl
    self.coordinate = coordinate
    self.creationDate = creationDate
  }
  
  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
    hasher.combine(imageUrl)
    hasher.combine(creationDate)
  }
  
  public var asUIImage: UIImage? {
    guard let data = image else { return nil }
    return UIImage(data: data)
  }
  
  public var jpegData: Data? {
    guard let image = asUIImage else {
      return nil
    }
    return image.jpegData(compressionQuality: 1.0)
  }
}

public extension PickerImageResult {
  init?(
    id: String = UUID().uuidString,
    uiImage: Data?,
    coordinate: CoordinateRegion.Coordinate? = nil,
    creationDate: Date? = nil
  ) {
    self.id = id
    self.image = uiImage
    self.coordinate = coordinate
    self.creationDate = creationDate
  }
}

extension Data {
  var isJPEG: Bool {
      guard count >= 2 else {
          return false
      }

      // Check for the JPEG file signature
      return self[0] == 0xFF && self[1] == 0xD8
  }
}
