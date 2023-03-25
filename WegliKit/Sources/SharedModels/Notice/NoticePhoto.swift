import Foundation
import UIKit

public struct NoticePhoto: Hashable, Codable {
  public var uiImage: UIImage?
  public let filename: String
  public let url: String
  
  enum CodingKeys: String, CodingKey {
    case filename, url
  }
  
  public init(filename: String, url: String) {
    self.filename = filename
    self.url = url
  }
  
  public init(uiImage: UIImage) {
    self.uiImage = uiImage
    self.filename = ""
    self.url = ""
  }
}

public extension NoticePhoto {
  static let loadingPreview1 = Self(uiImage: .init(systemName: "photo.fill")!)
  static let loadingPreview2 = Self(uiImage: .init(systemName: "swift")!)
}
