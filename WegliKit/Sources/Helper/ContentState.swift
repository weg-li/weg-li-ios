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
  public var systemImageName: String?
  public let title: String
  public var body: String?
  public var error: Error?

  public init(
    systemImageName: String? = nil,
    title: String,
    body: String? = nil,
    error: Error? = nil
  ) {
    self.systemImageName = systemImageName
    self.title = title
    self.body = body
    self.error = error
  }
}

public extension ErrorState {
  struct Error: Equatable, LocalizedError {
    public let errorDump: String
    public let message: String
    
    public init(error: Swift.Error) {
      var string = ""
      dump(error, to: &string)
      self.errorDump = string
      self.message = error.localizedDescription
    }
    
    public var errorDescription: String? {
      self.message
    }
  }
}
