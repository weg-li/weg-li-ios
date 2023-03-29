import Combine
import Dependencies
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
public struct APIService {
  public var getNotices: @Sendable (Bool) async throws -> [Notice]
  public var postNotice: @Sendable (NoticeInput) async throws -> Notice
  public var upload: @Sendable (PickerImageResult) async throws -> ImageUploadResponse
  public var submitNotice: @Sendable (NoticeInput) async throws -> Notice
  public var patchNotice: @Sendable (Notice) async throws -> Notice
  public var deleteNotice: @Sendable (String) async throws -> Bool

  public init(
    getNotices: @Sendable @escaping (Bool) async throws -> [Notice],
    postNotice: @Sendable @escaping (NoticeInput) async throws -> Notice,
    upload: @Sendable @escaping (PickerImageResult) async throws -> ImageUploadResponse,
    submitNotice: @Sendable @escaping (NoticeInput) async throws -> Notice,
    patchNotice: @Sendable @escaping (Notice) async throws -> Notice,
    deleteNotice: @Sendable @escaping (String) async throws -> Bool
  ) {
    self.getNotices = getNotices
    self.postNotice = postNotice
    self.upload = upload
    self.submitNotice = submitNotice
    self.patchNotice = patchNotice
    self.deleteNotice = deleteNotice
  }
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
      upload: { imagePickerResult in
        let input: ImageUploadInput? = .make(from: imagePickerResult)
        let body = try input?.encoded(encoder: .noticeEncoder)
        
        let request: Request = .post(.uploads, body: body)
        let responseData = try await apiClient.send(request)
        return try responseData.decoded(decoder: .noticeDecoder)
      },
      submitNotice: { notice in
        let body = try notice.encoded(encoder: .noticeEncoder)
        let data = try await apiClient.send(.patch(.submitNotices, body: body))
        
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
    upload: { _ in
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
    upload: { _ in
      throw NetworkRequestError.badRequest
    },
    submitNotice: { _ in throw ApiError(error: NetworkRequestError.decodingError) },
    patchNotice: { _ in throw ApiError(error: NetworkRequestError.decodingError) },
    deleteNotice: { _ in throw ApiError(error: NetworkRequestError.decodingError) }
  )
  
  public static var testValue: APIService = Self(
    getNotices: unimplemented("\(Self.self).getNotices"),
    postNotice: unimplemented("\(Self.self).postNotice"),
    upload: unimplemented("\(Self.self).upload"),
    submitNotice: unimplemented("\(Self.self).submitNotice"),
    patchNotice: unimplemented("\(Self.self).patchNotice"),
    deleteNotice: unimplemented("\(Self.self).deleteNotice")
  )
}

extension ApiError {
  public static let tokenUnavailable = Self(message: "API Token unavailable")
}
