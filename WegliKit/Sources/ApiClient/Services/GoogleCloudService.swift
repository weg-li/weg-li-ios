import Combine
import Dependencies
import DependenciesMacros
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

@DependencyClient
public struct GoogleUploadService {
  public var upload: @Sendable (
    _ url: URL?,
    _ body: Data?,
    _ headers: [String: String]
  ) async throws -> Void
}

extension GoogleUploadService: DependencyKey {
  public static var liveValue: GoogleUploadService = .live()
  
  static func live(networkDispatcher: NetworkDispatcher = .live) -> Self {
    Self(
      upload: { url, body, headers in
        guard let url else {
          throw NetworkRequestError.invalidRequest
        }
        var directUploadURLRequest = URLRequest(url: url)
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
    upload: { _, _, _ in }
  )
}
