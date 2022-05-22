import Foundation

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

public extension JSONDecoder {
  static let noticeDecoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    decoder.dateDecodingStrategy = .iso8601withFractionalSeconds
    return decoder
  }()
}
