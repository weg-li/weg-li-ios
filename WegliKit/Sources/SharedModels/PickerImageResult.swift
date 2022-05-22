// Created for weg-li in 2021.

import Foundation
import UIKit

public struct PickerImageResult: Hashable, Identifiable, Codable {
  public let id: String
  public let data: Data?
  public var imageUrl: URL?
  public var coordinate: CoordinateRegion.Coordinate?
  public var creationDate: Date?
  
  public init(
    id: String = UUID().uuidString,
    data: Data? = nil,
    imageUrl: URL? = nil,
    coordinate: CoordinateRegion.Coordinate? = nil,
    creationDate: Date? = nil
  ) {
    self.id = id
    self.data = data
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
    guard let imageUrl = imageUrl else {
      return nil
    }
    guard let data = try? Data(contentsOf: imageUrl) else { return nil }
    return UIImage(data: data)
  }
}

public extension PickerImageResult {
  init?(id: String = UUID().uuidString, uiImage: UIImage, imageUrl: URL? = nil) {
    guard let data = uiImage.pngData() else {
      return nil
    }
    self.data = data
    self.id = id
    self.imageUrl = imageUrl
  }
}
