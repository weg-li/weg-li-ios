import Dependencies
import Foundation
import XCTestDynamicOverlay

// MARK: Mocks

extension FileClient: TestDependencyKey {
  public static let noop = Self(
    removeItem: { _ in () },
    delete: { _ in () },
    load: { _ in throw CancellationError() },
    save: { _, _ in () }
  )
  
  public static let testValue: FileClient = Self(
    removeItem: unimplemented("\(Self.self).removeItem"),
    delete: unimplemented("\(Self.self).delete"),
    load: unimplemented("\(Self.self).load"),
    save: unimplemented("\(Self.self).save")
  )
}
