import Combine
import Foundation
import SharedModels

// Interface
/// A Service to send and fetch locations and chat messages from the Criticl Maps API
public struct NoticesService {
  public var getNotices: (String) -> AnyPublisher<[NoticeResponse], NSError>
  public var submitNotice: (String, Data?) -> AnyPublisher<[NoticeResponse], NSError>

  public init(
    getNotices: @escaping (String) -> AnyPublisher<[NoticeResponse], NSError>,
    submitNotice: @escaping (String, Data?) -> AnyPublisher<[NoticeResponse], NSError>
  ) {
    self.getNotices = getNotices
    self.submitNotice = submitNotice
  }
}

public extension NoticesService {
  static func live(apiClient: APIClient = .live) -> Self {
    Self(
      getNotices: { apiToken in
        let request = GetNoticesRequest(
          headers: [
            "application/json": "Content-Type",
            apiToken: "X-API-KEY"
          ]
        )
        
        return apiClient.dispatch(request)
          .decode(
            type: GetNoticesRequest.ResponseDataType.self,
            decoder: decoder
          )
          .mapError { $0 as NSError }
          .eraseToAnyPublisher()
      },
      submitNotice: { apiToken, data in
        let request = SubmitNoticeRequest(
          headers: [
            "application/json": "Content-Type",
            apiToken: "X-API-KEY"
          ],
          body: data
        )
        
        return apiClient.dispatch(request)
          .decode(
            type: SubmitNoticeRequest.ResponseDataType.self,
            decoder: decoder
          )
          .mapError { $0 as NSError }
          .eraseToAnyPublisher()
      }
    )
  }
}

public extension NoticesService {
  static let noop = Self(
    getNotices: { _ in
      Just([NoticeResponse.mock])
        .setFailureType(to: NSError.self)
        .eraseToAnyPublisher()
    },
    submitNotice: { _, _ in
      Just([NoticeResponse.mock])
        .setFailureType(to: NSError.self)
        .eraseToAnyPublisher()
    }
  )
  
  static let failing = Self(
    getNotices: { _ in
      Fail(error: NSError(domain: "", code: 1))
        .eraseToAnyPublisher()
    },
    submitNotice: { _, _ in
      Fail(error: NSError(domain: "", code: 1))
        .eraseToAnyPublisher()
    }
  )
}

let decoder: JSONDecoder = {
  let decoder = JSONDecoder()
  decoder.keyDecodingStrategy = .convertFromSnakeCase
  decoder.dateDecodingStrategy = .iso8601
  return decoder
}()
