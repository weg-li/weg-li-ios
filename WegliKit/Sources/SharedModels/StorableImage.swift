// Created for weg-li in 2021.

import Foundation
import UIKit

public struct StorableImage: Hashable, Identifiable, Codable {
  public let id: String
  public let image: Data
  public let imageUrl: URL?
  
  public init(id: String = UUID().uuidString, image: Data, imageUrl: URL? = nil) {
    self.id = id
    self.image = image
    self.imageUrl = imageUrl
  }
  
  public var asUIImage: UIImage? {
    UIImage(data: image)
  }
}

public extension StorableImage {
  init?(id: String = UUID().uuidString, uiImage: UIImage, imageUrl: URL? = nil) {
    guard let data = uiImage.pngData() else {
      return nil
    }
    self.image = data
    self.id = id
    self.imageUrl = imageUrl
  }
}
