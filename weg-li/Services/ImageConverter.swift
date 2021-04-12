// Created for weg-li in 2021.

import ComposableArchitecture
import UIKit

struct ImageConverter {
    var scalePreservingAspectRatio: (UIImage) -> Effect<UIImage, ImageConverterError>
}

extension ImageConverter {
    static func live(_ size: CGSize = .init(width: 1000, height: 1000)) -> Self {
        Self(
            scalePreservingAspectRatio: { image in
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
            }
        )
    }

    static let noop = Self(
        scalePreservingAspectRatio: { _ in .none }
    )
}

struct ImageConverterError: Equatable, Error {
    var message = ""
}
