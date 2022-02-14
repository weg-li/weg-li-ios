import ComposableArchitecture
import Combine
import SharedModels
import UIKit.UIImage
import UniformTypeIdentifiers

public extension ImageConverter {
  static func live(_ size: CGSize = .init(width: 1000, height: 1000)) -> Self {
    Self(
      scale: { image in
          .result {
            // Determine the scale factor that preserves aspect ratio
            let widthRatio = size.width / image.size.width
            let heightRatio = size.height / image.size.height
            
            let scaleFactor = min(widthRatio, heightRatio)
            
            // Compute the new image size that preserves aspect ratio
            let scaledImageSize = CGSize(
              width: image.size.width * scaleFactor,
              height: image.size.height * scaleFactor
            )
            
            // Draw and return the resized UIImage
            let renderer = UIGraphicsImageRenderer(
              size: scaledImageSize
            )
            
            let scaledImage = renderer.image { _ in
              image.draw(
                in: CGRect(
                  origin: .zero,
                  size: scaledImageSize
                )
              )
            }
            
            return .success(scaledImage)
          }
      },
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
            
            // Return the downsampled image as UIImage
            promise(.success(storableImage))
          }
      }
    )
  }
}
