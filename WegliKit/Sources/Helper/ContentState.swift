import Foundation
import UIKit

/// Wrapper type to represent the state of a loadable object. Typically from a network request
public enum ContentState<T: Equatable, Action>: Equatable {
  case loading
  case results(T)
  case empty(EmptyState<Action>)
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

public struct EmptyState<A>: Equatable {
  public let text: String
  public var message: NSAttributedString?
  public var action: Action?

  public init(
    text: String,
    message: NSAttributedString? = nil,
    action: Action? = nil
  ) {
    self.text = text
    self.message = message
    self.action = action
  }
  
  public struct Action: Equatable {
    public let label: String
    public var action: A
    
    public init(label: String, action: A) {
      self.label = label
      self.action = action
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
      lhs.label == rhs.label
    }
  }
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
      message
    }
  }
  
  static func loadingError(error: Error) -> Self {
    Self(
      systemImageName: "bolt.slash",
      title: "Fehler beim laden",
      body: "Der hinzugefügte API Token ist ungültig",
      error: .init(error: error)
    )
  }
  
  static let tokenUnavailable = Self(
    systemImageName: "key",
    title: "Kein API Token",
    body: "Füge deinen API Token in den Account Einstellungen hinzu um die App mit deinem weg.li Account zu verbinden"
  )
}
