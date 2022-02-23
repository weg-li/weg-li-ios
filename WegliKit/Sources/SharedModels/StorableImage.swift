// Created for weg-li in 2021.

import Foundation
import UIKit

public struct StorableImage: Hashable, Identifiable, Codable {
  public let id: String
  public let data: Data?
  public let imageUrl: URL?
  
  public init(id: String = UUID().uuidString, data: Data? = nil, imageUrl: URL? = nil) {
    self.id = id
    self.data = data
    self.imageUrl = imageUrl
  }
  
  public var asUIImage: UIImage? {
    self.data.flatMap(UIImage.init)
  }
}

public extension StorableImage {
  init?(id: String = UUID().uuidString, uiImage: UIImage, imageUrl: URL? = nil) {
    guard let data = uiImage.pngData() else {
      return nil
    }
    self.data = data
    self.id = id
    self.imageUrl = imageUrl
  }
}
