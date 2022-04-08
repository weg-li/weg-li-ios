// Created for weg-li in 2021.

import Foundation

public extension DateFormatter {
  static let dateFormatterWithoutTimeMediumStyle: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = 🇩🇪
    formatter.timeStyle = .none
    formatter.dateStyle = .medium
    return formatter
  }()
  
  static let dateFormatterMediumStyle: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = 🇩🇪
    formatter.timeStyle = .long
    formatter.dateStyle = .medium
    return formatter
  }()
}

public extension DateIntervalFormatter {
  static let reportTimeFormatter: DateIntervalFormatter = {
    let formatter = DateIntervalFormatter()
    formatter.dateStyle = .none
    formatter.timeStyle = .medium
    formatter.locale = 🇩🇪
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
