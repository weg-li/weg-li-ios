// Created for weg-li in 2021.

import Foundation

public extension DateFormatter {
  static let dateFormatterWithoutTimeMediumStyle: DateFormatter = {
    let formatter = DateFormatter()
    formatter.timeStyle = .none
    formatter.dateStyle = .medium
    formatter.locale = 🇩🇪
    formatter.timeZone = berlin
    return formatter
  }()
  
  static let dateFormatterMediumStyle: DateFormatter = {
    let formatter = DateFormatter()
    formatter.timeStyle = .long
    formatter.dateStyle = .medium
    formatter.locale = 🇩🇪
    formatter.timeZone = berlin
    return formatter
  }()
}

public extension DateIntervalFormatter {
  static let reportTimeFormatter: DateIntervalFormatter = {
    let formatter = DateIntervalFormatter()
    formatter.dateStyle = .none
    formatter.timeStyle = .medium
    formatter.locale = 🇩🇪
    formatter.timeZone = berlin
    return formatter
  }()
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

public extension Date {
  var humandReadableDate: String {
    DateFormatter.dateFormatterWithoutTimeMediumStyle.string(from: self)
  }
  
  var humandReadableTimeAndDate: String {
    DateFormatter.dateFormatterMediumStyle.string(from: self)
  }
}

let 🇩🇪 = Locale(identifier: "de_DE")
let berlin = TimeZone(identifier: "Europe/Berlin")!
