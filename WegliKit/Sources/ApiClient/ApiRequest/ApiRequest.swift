import Foundation

enum APIRequestBuildError: Error {
  case invalidURL
}

public protocol APIRequest {
  associatedtype ResponseDataType: Codable
  var endpoint: Endpoint { get }
  var httpMethod: HTTPMethod { get }
  var headers: HTTPHeaders? { get }
  var queryItems: [URLQueryItem] { get set }
  var body: Data? { get }
  var cachePolicy: URLRequest.CachePolicy { get set }
  func makeRequest() throws -> URLRequest
}

public extension APIRequest {
  var queryItems: [String: String] { [:] }
  var cachePolicy: URLRequest.CachePolicy { .useProtocolCachePolicy }
  
  func makeRequest() throws -> URLRequest {
    var components = URLComponents()
    components.scheme = "https"
    components.host = endpoint.baseUrl
    if let path = endpoint.path {
      components.path = path
    }
    if !queryItems.isEmpty {
      components.queryItems = queryItems
    }
    guard let url = components.url else {
      throw APIRequestBuildError.invalidURL
    }
    var request = URLRequest(url: url)
    request.httpMethod = httpMethod.rawValue
    request.addHeaders(headers)
    if let body = body {
      request.httpBody = body
    }
    request.cachePolicy = cachePolicy
    return request
  }
}

extension URLRequest {
  mutating func addHeaders(_ httpHeaders: HTTPHeaders?) {
    guard let headers = httpHeaders else {
      return
    }
    for header in headers {
      addValue(header.key, forHTTPHeaderField: header.value)
    }
  }
}
