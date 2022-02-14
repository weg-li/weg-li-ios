import ComposableArchitecture
import Combine
import UIKit.UIImage

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
          .result {
            let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
            guard let imageSource = CGImageSourceCreateWithURL(imageURL as CFURL, imageSourceOptions) else {
              return .failure(.init(message: "Source can not be created"))
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
              return .failure(.init(message: "Creates a thumbnail failed"))
            }
            
            // Return the downsampled image as UIImage
            return .success(UIImage(cgImage: downsampledImage))
          }
      }
    )
  }
}
