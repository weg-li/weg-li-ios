import ComposableArchitecture
import Combine
import SharedModels
import UIKit.UIImage

public struct ImageConverter {
  public init(
    downsample: @escaping (URL, CGSize, CGFloat) -> Effect<StorableImage?, ImageConverterError>
  ) {
    self.downsample = downsample
  }
  
  public var downsample: (URL, CGSize, CGFloat) -> Effect<StorableImage?, ImageConverterError>
  
  public func downsample(
    _ imageUrl: URL,
    to pointSize: CGSize = .init(width: 1536, height: 1536),
    scale: CGFloat = UIScreen.main.scale,
    on queue: AnySchedulerOf<DispatchQueue>
  ) -> Effect<StorableImage?, Never> {
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
