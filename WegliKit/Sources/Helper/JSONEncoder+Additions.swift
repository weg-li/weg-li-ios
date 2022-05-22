import Foundation

public extension JSONEncoder.DateEncodingStrategy {
  static let iso8601withFractionalSeconds = custom { date, encoder in
    var container = encoder.singleValueContainer()
    let dateString = ISO8601DateFormatter.internetDateTimeWithFractionalSeconds.string(from: date)
    try container.encode(dateString)
  }
}

public extension JSONEncoder {
  static let noticeEncoder: JSONEncoder = {
    let decoder = JSONEncoder()
    decoder.keyEncodingStrategy = .convertToSnakeCase
    decoder.dateEncodingStrategy = .iso8601withFractionalSeconds
    return decoder
  }()
}
