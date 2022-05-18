import Foundation
import SharedModels

public struct SubmitNoticeRequest: APIRequest {
  public var queryItems: [URLQueryItem] = []
  public typealias ResponseDataType = [Notice]
  public let endpoint: Endpoint
  public var headers: HTTPHeaders? = .contentTypeApplicationJSON
  public let httpMethod: HTTPMethod
  public var body: Data?
  
  public init(
    endpoint: Endpoint = .submitNotice,
    apiToken: String,
    httpMethod: HTTPMethod = .patch,
    body: Data?
  ) {
    self.endpoint = endpoint
    self.headers?[apiTokenKey] = apiToken
    self.httpMethod = httpMethod
    self.body = body
  }
}

public struct GetNoticesRequest: APIRequest {
  public var queryItems: [URLQueryItem] = []
  public typealias ResponseDataType = [Notice]
  public let endpoint: Endpoint
  public var headers: HTTPHeaders? = .contentTypeApplicationJSON
  public let httpMethod: HTTPMethod
  public var body: Data?
  
  public init(
    endpoint: Endpoint = .notices,
    apiToken: String,
    httpMethod: HTTPMethod = .get,
    body: Data? = nil
  ) {
    self.endpoint = endpoint
    self.headers?[apiTokenKey] = apiToken
    self.httpMethod = httpMethod
    self.body = body
  }
}

private let apiTokenKey = "X-API-KEY"
