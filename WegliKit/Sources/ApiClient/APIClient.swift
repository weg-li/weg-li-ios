import Combine
import Foundation

/// A Client to dispatch network calls
public struct APIClient {
  var networkDispatcher: () -> NetworkDispatcher
  
  public init(networkDispatcher: @escaping () -> NetworkDispatcher) {
    self.networkDispatcher = networkDispatcher
  }
  
  /// Dispatches a Request and returns a publisher
  /// - Parameter request: Request to Dispatch
  /// - Returns: A publisher containing decoded data or an error
  public func dispatch<R: APIRequest>(_ request: R) -> AnyPublisher<Data, NetworkRequestError> {
    guard let urlRequest = try? request.makeRequest() else {
      return Fail(
        outputType: Data.self,
        failure: NetworkRequestError.badRequest
      )
      .eraseToAnyPublisher()
    }
    return networkDispatcher()
      .dispatch(request: urlRequest)
      .eraseToAnyPublisher()
  }
}

public extension APIClient {
  static let live = Self(networkDispatcher: { .live })
  static let noop = Self(networkDispatcher: { .noop })
}
