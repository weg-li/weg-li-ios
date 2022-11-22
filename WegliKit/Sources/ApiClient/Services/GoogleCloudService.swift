import Combine
import Dependencies
import Foundation
import Helper
import SharedModels
import XCTestDynamicOverlay

extension DependencyValues {
  public var googleUploadService: GoogleUploadService {
    get { self[GoogleUploadService.self] }
    set { self[GoogleUploadService.self] = newValue }
  }
}

public struct GoogleUploadService {
  public var upload: @Sendable (URL?, [URLQueryItem]?, Data?, [String: String]) async throws -> Void

  public init(upload: @Sendable @escaping (URL?, [URLQueryItem]?, Data?, [String: String]) async throws -> Void) {
    self.upload = upload
  }
}

public extension GoogleUploadService {
  static func live(networkDispatcher: NetworkDispatcher = .live) -> Self {
    Self(
      upload: { url, _, body, headers in
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
        _ = try await networkDispatcher.dispatch(request: directUploadURLRequest)
      }
    )
  }
}

extension GoogleUploadService: TestDependencyKey {
  public static let noop = Self(
    upload: { _, _, _, _ in }
  )
  
  public static var testValue: GoogleUploadService = Self(
    upload: unimplemented("\(Self.self).upload")
  )
}
