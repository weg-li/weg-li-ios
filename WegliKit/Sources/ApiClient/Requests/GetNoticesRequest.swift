import Foundation
import SharedModels

public struct GetNoticesRequest: APIRequest {
  public var queryItems: [URLQueryItem] = []
  public typealias ResponseDataType = [NoticeResponse]
  public let endpoint: Endpoint
  public let headers: HTTPHeaders?
  public let httpMethod: HTTPMethod
  public var body: Data?
  
  public init(
    endpoint: Endpoint = .notices,
    headers: HTTPHeaders? = .contentTypeApplicationJSON,
    httpMethod: HTTPMethod = .get,
    body: Data? = nil
  ) {
    self.endpoint = endpoint
    self.headers = headers
    self.httpMethod = httpMethod
    self.body = body
  }
}
