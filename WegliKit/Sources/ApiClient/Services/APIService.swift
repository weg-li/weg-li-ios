import Combine
import Dependencies
import DependenciesMacros
import Foundation
import Helper
import SharedModels
import XCTestDynamicOverlay

extension DependencyValues {
  public var apiService: APIService {
    get { self[APIService.self] }
    set { self[APIService.self] = newValue }
  }
}


/// A Service to send a single notice and all persisted notices from the weg-li API
@DependencyClient
public struct APIService {
  public var getNotices: @Sendable (Bool) async throws -> [Notice]
  public var postNotice: @Sendable (NoticeInput) async throws -> Notice
  public var upload: @Sendable (_ id: PickerImageResult.ID, _ imageData: Data?) async throws -> ImageUploadResponse
  public var submitNotice: @Sendable (NoticeInput) async throws -> Notice
  public var patchNotice: @Sendable (Notice) async throws -> Notice
  public var deleteNotice: @Sendable (String) async throws -> Bool
}

extension APIService: DependencyKey {
  public static var liveValue: APIService = .live()
  
  static func live(apiClient: APIClient = .live) -> Self {
    Self(
      getNotices: { forceReload in
        let data = try await apiClient.send(.getNotices(forceReload: forceReload))
        
        return try data.decoded(decoder: .noticeDecoder)
      },
      postNotice: { notice in
        let body = try notice.encoded(encoder: .noticeEncoder)
        let data = try await apiClient.send(.post(.notices, body: body))
        
        return try data.decoded(decoder: .noticeDecoder)
      },
      upload: { id, imageData in
        guard let data = imageData else {
          throw ApiError(message: "no data provided")
        }
        let input: ImageUploadInput = .make(id: id, data: data)
        let body = try input.encoded(encoder: .noticeEncoder)
        
        let request: Request = .post(.uploads, body: body)
        let responseData = try await apiClient.send(request)
        return try responseData.decoded(decoder: .noticeDecoder)
      },
      submitNotice: { notice in
        let body = try notice.encoded(encoder: .noticeEncoder)
        let data = try await apiClient.send(.patch(.submitNotices(id: notice.id), body: body))
        
        return try data.decoded(decoder: .noticeDecoder)
      },
      patchNotice: { notice in
        let body = try notice.encoded(encoder: .noticeEncoder)
        let data = try await apiClient.send(.patch(.updateNotice(token: notice.id), body: body))
        
        return try data.decoded(decoder: .noticeDecoder)
      },
      deleteNotice: { token in
        let endpoint: Endpoint = .updateNotice(token: token)
        let request = Request(endpoint: endpoint, httpMethod: .delete)
        
        _ = try await apiClient.send(request)
        return true
      }
    )
  }
}

extension APIService: TestDependencyKey {
  public static let noop = Self(
    getNotices: { _ in
      [.mock, .mock]
    },
    postNotice: { _ in
      .mock
    },
    upload: { _, _ in
      ImageUploadResponse(
        id: 1,
        key: "",
        filename: "",
        contentType: "",
        byteSize: 0,
        checksum: "",
        createdAt: .init(timeIntervalSince1970: 0),
        signedId: "",
        directUpload: .init(
          url: "",
          headers: [:]
        )
      )
    },
    submitNotice: { _ in .mock },
    patchNotice: { _ in .mock },
    deleteNotice: { _ in true }
  )
  
  public static let failing = Self(
    getNotices: { _ in
      throw ApiError(error: NetworkRequestError.invalidRequest)
    },
    postNotice: { _ in
      throw ApiError(error: NetworkRequestError.invalidRequest)
    },
    upload: { _, _ in
      throw NetworkRequestError.badRequest
    },
    submitNotice: { _ in throw ApiError(error: NetworkRequestError.decodingError) },
    patchNotice: { _ in throw ApiError(error: NetworkRequestError.decodingError) },
    deleteNotice: { _ in throw ApiError(error: NetworkRequestError.decodingError) }
  )
}

extension ApiError {
  public static let tokenUnavailable = Self(message: "API Token unavailable")
}
