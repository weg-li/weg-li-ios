// Created for weg-li in 2021.

import Foundation
import UIKit

public struct StorableImage: Hashable, Identifiable, Codable {
  public let id: String
  public let image: Data
  
  public init(id: String = UUID().uuidString, image: Data) {
    self.id = id
    self.image = image
  }
  
  public var asUIImage: UIImage? {
    UIImage(data: image)
  }
}

public extension StorableImage {
  init?(id: String = UUID().uuidString, uiImage: UIImage) {
    guard let data = uiImage.pngData() else {
      return nil
    }
    image = data
    self.id = id
  }
}
