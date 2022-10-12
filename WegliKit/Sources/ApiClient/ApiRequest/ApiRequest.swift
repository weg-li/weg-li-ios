import Foundation

enum APIRequestBuildError: Error {
  case invalidURL
}

public struct Request {
  let endpoint: Endpoint
  let httpMethod: HTTPMethod
  var headers: [String: String] = ["Content-Type": "application/json"]
  var queryItems: [URLQueryItem] = []
  var body: Data? = nil
  var cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy
  
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
    request.allHTTPHeaderFields = headers
    if let body = body {
      request.httpBody = body
    }
    request.cachePolicy = cachePolicy
    return request
  }
}

public extension Request {
  static func get(_ endpoint: Endpoint, query: [URLQueryItem] = []) -> Request {
    Request(endpoint: endpoint, httpMethod: .get, queryItems: query)
  }
  
  static func post(_ endpoint: Endpoint, body: Data?) -> Request {
    Request(endpoint: endpoint, httpMethod: .post, body: body)
  }
  
  static func patch(_ endpoint: Endpoint, body: Data?) -> Request {
    Request(endpoint: endpoint, httpMethod: .patch, body: body)
  }
}
