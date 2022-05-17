import Combine
import Foundation
import SharedModels

// Interface
/// A Service to send a single notice and all persisted notices from the weg-li API
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
        let request = GetNoticesRequest(apiToken: apiToken)
        
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
          apiToken: apiToken,
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

public extension ISO8601DateFormatter {
  static let internetDateTimeWithFractionalSeconds: ISO8601DateFormatter = {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [
      .withInternetDateTime,
      .withFractionalSeconds
    ]
    return formatter
  }()
}

public extension JSONDecoder.DateDecodingStrategy {
  static let iso8601withFractionalSeconds = custom { decoder in
    let container = try decoder.singleValueContainer()
    let dateString = try container.decode(String.self)
    
    guard let date = ISO8601DateFormatter.internetDateTimeWithFractionalSeconds.date(from: dateString)  else {
      throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date: \(dateString)")
    }
    return date
  }
}

private let decoder: JSONDecoder = {
  let decoder = JSONDecoder()
  decoder.keyDecodingStrategy = .convertFromSnakeCase
  decoder.dateDecodingStrategy = .iso8601withFractionalSeconds
  return decoder
}()
