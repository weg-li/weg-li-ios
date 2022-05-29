import Combine
import ComposableArchitecture
import Foundation
import Helper
import SharedModels

public struct GoogleUploadService {
  public var upload: (URL?, [URLQueryItem]?, Data?, [String: String]) async throws -> Void

  public init(upload: @escaping (URL?, [URLQueryItem]?, Data?, [String: String]) async throws -> Void) {
    self.upload = upload
  }
}

public extension GoogleUploadService {
  static func live(networkDispatcher: NetworkDispatcher = .live) -> Self {
    Self(
      upload: { url, queryItems, body, headers in
        guard let url = url else {
          throw NetworkRequestError.invalidRequest
        }
        let directUploadURLComponents = URLComponents(
          url: url,
          resolvingAgainstBaseURL: false
        )
        var directUploadURLRequest = URLRequest(url: (directUploadURLComponents?.url)!)
        directUploadURLRequest.httpBody = body
        directUploadURLRequest.httpMethod = HTTPMethod.put.rawValue
        for (key, value) in headers {
          directUploadURLRequest.addValue(value, forHTTPHeaderField: key)
        }        
        let _ = try await networkDispatcher.dispatch(request: directUploadURLRequest)
        return
      }
    )
  }
}

public extension GoogleUploadService {
  static let noop = Self(
    upload: { _, _, _, _ in return }
  )
}
