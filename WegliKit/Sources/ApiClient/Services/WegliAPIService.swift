import Combine
import ComposableArchitecture
import Foundation
import Helper
import SharedModels

// Interface
/// A Service to send a single notice and all persisted notices from the weg-li API
public struct WegliAPIService {
  public var getNotices: () -> Effect<[Notice], NSError>
  public var postNotice: (Data?) -> Effect<Result<Notice, NSError>, Never>
  public var upload: (UploadImageRequest) async throws -> ImageUploadResponse

  public init(
    getNotices: @escaping () -> Effect<[Notice], NSError>,
    postNotice: @escaping (Data?) -> Effect<Result<Notice, NSError>, Never>,
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
      getNotices: {
        let request = GetNoticesRequest()
        
        return apiClient.dispatch(request)
          .decode(
            type: GetNoticesRequest.ResponseDataType.self,
            decoder: JSONDecoder.noticeDecoder
          )
          .mapError { $0 as NSError }
          .eraseToEffect()
      },
      postNotice: { data in
        let request = SubmitNoticeRequest(body: data)
        
        return apiClient.dispatch(request)
          .decode(
            type: SubmitNoticeRequest.ResponseDataType.self,
            decoder: JSONDecoder.noticeDecoder
          )
          .mapError { $0 as NSError }
          .catchToEffect()
          .eraseToEffect()
      },
      upload: {
        let responseData = try await apiClient.dispatch($0)
        return try JSONDecoder.noticeDecoder.decode(ImageUploadResponse.self, from: responseData)
      }
    )
  }
}

public extension WegliAPIService {
  static let noop = Self(
    getNotices: {
      Just([Notice.mock])
        .setFailureType(to: NSError.self)
        .eraseToEffect()
    },
    postNotice: { _ in
      Just(.mock)
        .setFailureType(to: NSError.self)
        .catchToEffect()
        .eraseToEffect()
    },
    upload: { _ in
      return ImageUploadResponse(
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
    getNotices: {
      Fail(error: NSError(domain: "", code: 1))
        .eraseToEffect()
    },
    postNotice: { _ in
      Fail(error: NSError(domain: "", code: 1))
        .catchToEffect()
        .eraseToEffect()
    },
    upload: { _ in
      throw NetworkRequestError.badRequest
    }
  )
}
