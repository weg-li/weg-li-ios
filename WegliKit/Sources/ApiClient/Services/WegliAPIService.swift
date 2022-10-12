import Combine
import Foundation
import Helper
import SharedModels

// Interface
/// A Service to send a single notice and all persisted notices from the weg-li API
public struct WegliAPIService {
  public var getNotices: @Sendable (Bool) async throws -> [Notice]
  public var postNotice: @Sendable (NoticeInput) async throws -> Notice
  public var upload: @Sendable (PickerImageResult) async throws -> ImageUploadResponse
  public var submitNotice: @Sendable (NoticeInput) async throws -> Notice

  public init(
    getNotices: @Sendable @escaping (Bool) async throws -> [Notice],
    postNotice: @Sendable @escaping (NoticeInput) async throws -> Notice,
    upload: @Sendable @escaping (PickerImageResult) async throws -> ImageUploadResponse,
    submitNotice: @Sendable @escaping (NoticeInput) async throws -> Notice
  ) {
    self.getNotices = getNotices
    self.postNotice = postNotice
    self.upload = upload
    self.submitNotice = submitNotice
  }
}

public extension WegliAPIService {
  static func live(apiClient: APIClient = .live) -> Self {
    Self(
      getNotices: { forceReload in
        let data = try await apiClient.send(.getNotices(forceReload: forceReload))
        
        return try data.decoded(decoder: .noticeDecoder)
      },
      postNotice: { input in
        let noticePutRequestBody = NoticePutRequestBody(notice: input)
        let body = try noticePutRequestBody.encoded(encoder: .noticeEncoder)
        
        let data = try await apiClient.send(.createNotice(body: body))
        
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
        let noticePutRequestBody = NoticePutRequestBody(notice: notice)
        let body = try noticePutRequestBody.encoded(encoder: .noticeEncoder)
        
        let data = try await apiClient.send(.post(.submitNotices, body: body))
        
        return try data.decoded(decoder: .noticeDecoder)
      }
    )
  }
}

public extension WegliAPIService {
  static let noop = Self(
    getNotices: { _ in
      [Notice.mock]
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
    submitNotice: { _ in .mock }
  )
  
  static let failing = Self(
    getNotices: { _ in
      throw ApiError(error: NetworkRequestError.invalidRequest)
    },
    postNotice: { _ in
      throw ApiError(error: NetworkRequestError.invalidRequest)
    },
    upload: { _ in
      throw NetworkRequestError.badRequest
    },
    submitNotice: { _ in fatalError() }
  )
}
