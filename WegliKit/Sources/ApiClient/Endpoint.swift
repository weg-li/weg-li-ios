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
  static func updateNotice(token: String) -> Self {
    Self(baseUrl: Endpoints.wegliAPIEndpoint, path: "/api/notices/\(token)")
  }
  /// `/api/notices` endpoint
  static let notices = Self(baseUrl: Endpoints.wegliAPIEndpoint, path: "/api/notices")
  /// `/api/uploads` endpoint
  static let uploads = Self(baseUrl: Endpoints.wegliAPIEndpoint, path: "/api/uploads")
  /// `/api/notices/mail` endpoint
  static let submitNotices = Self(baseUrl: Endpoints.wegliAPIEndpoint, path: "/api/notices/mail")
}
