import Combine
import ComposableArchitecture
import Foundation
import Helper
import SharedModels

// Interface
/// A Service to send a single notice and all persisted notices from the weg-li API
public struct NoticesService {
  public var getNotices: () -> Effect<[Notice], NSError>
  public var postNotice: (Data?) -> Effect<Result<Notice, NSError>, Never>

  public init(
    getNotices: @escaping () -> Effect<[Notice], NSError>,
    postNotice: @escaping (Data?) -> Effect<Result<Notice, NSError>, Never>
  ) {
    self.getNotices = getNotices
    self.postNotice = postNotice
  }
}

public extension NoticesService {
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
      }
    )
  }
}

public extension NoticesService {
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
    }
  )
}
