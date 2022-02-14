import ComposableArchitecture
import Combine
import UIKit.UIImage

public struct ImageConverter {
  public init(
    scale: @escaping (UIImage) -> Effect<UIImage, ImageConverterError>,
    downsample: @escaping (URL, CGSize, CGFloat) -> Effect<UIImage, ImageConverterError>
  ) {
    self.scale = scale
    self.downsample = downsample
  }
  
  public var scale: (UIImage) -> Effect<UIImage, ImageConverterError>
  public var downsample: (URL, CGSize, CGFloat) -> Effect<UIImage, ImageConverterError>
  
  public func downsample(
    _ imageUrl: URL,
    to pointSize: CGSize,
    scale: CGFloat = UIScreen.main.scale,
    on queue: AnySchedulerOf<DispatchQueue>
  ) -> Effect<UIImage, Never> {
    Just(imageUrl)
      .subscribe(on: queue)
      .flatMap { imageUrl in
        self.downsample(imageUrl, pointSize, scale)
      }
      .catch { _ in Empty() }
      .setFailureType(to: Never.self)
      .eraseToEffect()
  }
}


public struct ImageConverterError: Equatable, Error {
  public init(message: String = "") {
    self.message = message
  }
  
  var message = ""
}
