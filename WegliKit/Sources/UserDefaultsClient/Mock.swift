import ComposableArchitecture
import Foundation

public extension UserDefaultsClient {
  static let noop = Self(
    boolForKey: { _ in false },
    dataForKey: { _ in nil },
    doubleForKey: { _ in 0 },
    remove: { _ in .none },
    setBool: { _, _ in .none },
    setData: { _, _ in .none },
    setDouble: { _, _ in .none }
  )
}
