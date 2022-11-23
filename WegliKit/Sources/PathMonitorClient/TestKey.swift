import Dependencies
import Foundation
import Network
import XCTestDynamicOverlay

extension PathMonitorClient: TestDependencyKey {
  public static let satisfied = Self {
    AsyncStream { continuation in
      continuation.yield(NetworkPath(status: .satisfied))
      continuation.finish()
    }
  }

  public static let unsatisfied = Self {
    AsyncStream { continuation in
      continuation.yield(NetworkPath(status: .unsatisfied))
      continuation.finish()
    }
  }
  
  public static var testValue: PathMonitorClient = Self(
    networkPathPublisher: unimplemented("\(Self.self).networkPathPublisher")
  )
}
