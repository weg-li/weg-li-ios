import Foundation
import UIKit

/// Wrapper type to represent the state of a loadable object. Typically from a network request
public enum ContentState<T: Equatable>: Equatable {
  case loading(T)
  case results(T)
  case empty(EmptyState)
  case error(ErrorState)
  
  public var elements: T? {
    switch self {
    case let .results(results):
      return results
    default:
      return nil
    }
  }
}

public struct EmptyState: Equatable {
  public let icon: UIImage
  public let text: String
  public var message: NSAttributedString?

  public init(
    icon: UIImage,
    text: String,
    message: NSAttributedString? = nil
  ) {
    self.icon = icon
    self.text = text
    self.message = message
  }
}

public struct ErrorState: Equatable {
  public let title: String
  public let body: String?
  public let error: NSError?
  
  public init(title: String, body: String?, error: NSError? = nil) {
    self.title = title
    self.body = body
    self.error = error
  }
}
