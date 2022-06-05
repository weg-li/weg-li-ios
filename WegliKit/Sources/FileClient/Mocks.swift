import Foundation

// MARK: Mocks

public extension FileClient {
  static let noop = Self(
    removeItem: { _ in .none },
    delete: { _ in .none },
    load: { _ in .none },
    save: { _, _ in .none }
  )
}
