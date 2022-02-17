import ComposableArchitecture
import Combine
import SharedModels
import UIKit.UIImage
import UniformTypeIdentifiers

public extension ImageConverter {
  static func live() -> Self {
    Self(
      downsample: { imageURL, pointSize, scale in
          .future { promise in
            let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
            guard let imageSource = CGImageSourceCreateWithURL(imageURL as CFURL, imageSourceOptions) else {
              promise(.failure(.init(message: "Source can not be created")))
              assertionFailure()
              return
            }
            
            // Calculate the desired dimension
            let maxDimensionInPixels = max(pointSize.width, pointSize.height) * scale
            
            // Perform downsampling
            let downsampleOptions = [
              kCGImageSourceCreateThumbnailFromImageAlways: true,
              kCGImageSourceShouldCacheImmediately: true,
              kCGImageSourceCreateThumbnailWithTransform: true,
              kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels
            ] as CFDictionary
            
            guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) else {
              promise(.success(nil))
              return
            }
            
            let data = NSMutableData()
            guard let imageDestination = CGImageDestinationCreateWithData(data, UTType.jpeg.identifier as CFString, 1, nil) else {
              promise(.success(nil))
              assertionFailure()
              return
            }
            
            let destinationProperties = [
              kCGImageDestinationLossyCompressionQuality: 0.9
            ] as CFDictionary
            
            CGImageDestinationAddImage(imageDestination, downsampledImage, destinationProperties)
            CGImageDestinationFinalize(imageDestination)
            
            let dataSize = ByteCountFormatter.string(fromByteCount: Int64(data.length), countStyle: .memory)
            debugPrint("\((#file as NSString).lastPathComponent)[\(#line)], \(#function): load image \(dataSize)")
            
            let storableImage = StorableImage(
              data: data as Data,
              imageUrl: imageURL
            )
            
            promise(.success(storableImage))
          }
      }
    )
  }
}
