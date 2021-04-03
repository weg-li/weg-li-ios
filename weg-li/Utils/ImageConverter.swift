// Created for weg-li in 2021.

import UIKit

protocol ImageConverter {
    func scalePreservingAspectRatio(image: UIImage, targetSize: CGSize) -> UIImage
}

struct ImageConverterImplementation: ImageConverter {
    func scalePreservingAspectRatio(image: UIImage, targetSize: CGSize) -> UIImage {
        // Determine the scale factor that preserves aspect ratio
        let widthRatio = targetSize.width / image.size.width
        let heightRatio = targetSize.height / image.size.height

        let scaleFactor = min(widthRatio, heightRatio)

        // Compute the new image size that preserves aspect ratio
        let scaledImageSize = CGSize(
            width: image.size.width * scaleFactor,
            height: image.size.height * scaleFactor)

        // Draw and return the resized UIImage
        let renderer = UIGraphicsImageRenderer(
            size: scaledImageSize
        )

        let scaledImage = renderer.image { _ in
            image.draw(
                in: CGRect(
                    origin: .zero,
                    size: scaledImageSize)
            )
        }

        return scaledImage
    }
}
