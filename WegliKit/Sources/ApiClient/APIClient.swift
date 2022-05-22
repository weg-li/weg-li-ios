import Combine
import Foundation
import KeychainClient

/// A Client to dispatch network calls
public struct APIClient {
  var networkDispatcher: () -> NetworkDispatcher
  var tokenStore: () -> KeychainClient
  
  public init(
    networkDispatcher: @escaping () -> NetworkDispatcher,
    tokenStore: @escaping () -> KeychainClient
  ) {
    self.networkDispatcher = networkDispatcher
    self.tokenStore = tokenStore
  }
  
  /// Dispatches a Request and returns a publisher
  /// - Parameter request: Request to Dispatch
  /// - Returns: A publisher containing decoded data or an error
  public func dispatch<R: APIRequest>(_ request: R) -> AnyPublisher<Data, NetworkRequestError> {
    guard var urlRequest = try? request.makeRequest() else {
      return Fail(
        outputType: Data.self,
        failure: NetworkRequestError.badRequest
      )
      .eraseToAnyPublisher()
    }
    if let token = tokenStore().getToken() {
      urlRequest.addValue(token, forHTTPHeaderField: "X-API-KEY")
    }
    
    return networkDispatcher()
      .dispatch(request: urlRequest)
      .eraseToAnyPublisher()
  }
  
  /// Dispatches a Request and returns a publisher
  /// - Parameter request: Request to Dispatch
  /// - Returns: A publisher containing decoded data or an error
  public func dispatch<R: APIRequest>(_ request: R) async throws -> Data {
    guard var urlRequest = try? request.makeRequest() else {
      throw NetworkRequestError.badRequest
    }
    if let token = tokenStore().getToken() {
      urlRequest.addValue(token, forHTTPHeaderField: "X-API-KEY")
    }
    
    return try await networkDispatcher().dispatch(request: urlRequest)
  }
}

public extension APIClient {
  static let live = Self(networkDispatcher: { .live }, tokenStore: { .live() })
  static let noop = Self(networkDispatcher: { .noop }, tokenStore: { .noop })
}
