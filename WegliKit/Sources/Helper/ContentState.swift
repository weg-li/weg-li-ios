import Foundation
import UIKit

/// Wrapper type to represent the state of a loadable object. Typically from a network request
public enum ContentState<T: Equatable>: Equatable {
  case loading
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
  public let text: String
  public var message: NSAttributedString?

  public init(
    text: String,
    message: NSAttributedString? = nil
  ) {
    self.text = text
    self.message = message
  }
}

public extension EmptyState {
  static let emptyNotices = Self(text: "Keine Anzeigen", message: nil)
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
