// Created for weg-li in 2021.

import Foundation
import UIKit

public struct PickerImageResult: Hashable, Identifiable, Codable {
  public let id: String
  public var imageUrl: URL?
  public var coordinate: CoordinateRegion.Coordinate?
  public var creationDate: Date?
  
  public var jpegData: Data? {
    guard
      let imageUrl = imageUrl,
      let imageData = try? Data(contentsOf: imageUrl)
    else {
      return nil
    }
    
    if imageData.isJPEG {
      return imageData
    } else {
      return UIImage(data: imageData)?.jpegData(compressionQuality: 0.9)
    }
  }

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
    guard let data = jpegData else { return nil }
    return UIImage(data: data)
  }
}

public extension PickerImageResult {
  init?(id: String = UUID().uuidString, uiImage: UIImage, imageUrl: URL? = nil) {
    self.id = id
    self.imageUrl = imageUrl
  }
}

private func resizedImage(at url: URL, for targetSize: CGSize = CGSize(width: 1000, height: 1000)) -> UIImage? {
  guard let image = UIImage(contentsOfFile: url.path) else {
    return nil
  }
  
  let widthScaleRatio = targetSize.width / image.size.width
  let heightScaleRatio = targetSize.height / image.size.height
  let scaleFactor = min(widthScaleRatio, heightScaleRatio)
  let scaledImageSize = CGSize(
    width: image.size.width * scaleFactor,
    height: image.size.height * scaleFactor
  )
  
  let renderer = UIGraphicsImageRenderer(size: scaledImageSize)
  return renderer.image { _ in
    image.draw(in: CGRect(origin: .zero, size: scaledImageSize))
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
