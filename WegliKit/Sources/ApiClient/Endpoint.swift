import Foundation

/// A structure to define an endpoint on the Critical Maps API
public struct Endpoint {
  public let baseUrl: String
  public let path: String?
  
  public init(baseUrl: String = Endpoints.wegliAPIEndpoint, path: String? = nil) {
    self.baseUrl = baseUrl
    self.path = path
  }
}

public extension Endpoint {
  static let notices = Self(
    baseUrl: Endpoints.wegliAPIEndpoint,
    path: "/api/notices"
  )
  
  static let submitNotice = Self(
    baseUrl: Endpoints.wegliAPIEndpoint,
    path: "/api/notices/mail"
  )
}
