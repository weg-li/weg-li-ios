import Combine
import ComposableArchitecture
import Foundation
import Helper
import SharedModels

// Interface
/// A Service to send a single notice and all persisted notices from the weg-li API
public struct WegliAPIService {
  public var getNotices: (Bool) async throws -> [Notice]
  public var postNotice: @Sendable (NoticeInput) async throws -> Notice
  public var upload: (UploadImageRequest) async throws -> ImageUploadResponse

  public init(
    getNotices: @escaping (Bool) async throws -> [Notice],
    postNotice: @Sendable @escaping (NoticeInput) async throws -> Notice,
    upload: @escaping (UploadImageRequest) async throws -> ImageUploadResponse
  ) {
    self.getNotices = getNotices
    self.postNotice = postNotice
    self.upload = upload
  }
}

public extension WegliAPIService {
  static func live(apiClient: APIClient = .live) -> Self {
    Self(
      getNotices: { forceReload in
        let request = GetNoticesRequest(forceReload: forceReload)
        
        let data = try await apiClient.dispatch(request)
        
        return try JSONDecoder.noticeDecoder.decode(
          GetNoticesRequest.ResponseDataType.self,
          from: data
        )
      },
      postNotice: { input in
        let noticePutRequestBody = NoticePutRequestBody(notice: input)
        let body = try? JSONEncoder.noticeEncoder.encode(noticePutRequestBody)
        
        let request = SubmitNoticeRequest(body: body)
        let data = try await apiClient.dispatch(request)
        
        return try JSONDecoder.noticeDecoder.decode(
          SubmitNoticeRequest.ResponseDataType.self,
          from: data
        )
      },
      upload: { imageUploadRequest in
        let responseData = try await apiClient.dispatch(imageUploadRequest)
        return try JSONDecoder.noticeDecoder.decode(ImageUploadResponse.self, from: responseData)
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
    }
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
    }
  )
}
