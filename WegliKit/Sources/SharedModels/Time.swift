// Created for weg-li in 2021.

import Foundation
import L10n

public enum Times {
  public static let times: [Int: String] = [
    0: "",
    1: "bis zu 2 Minuten",
    2: "länger als 2 Minuten",
    3: "länger als 3 Minuten",
    4: "länger als 4 Minuten",
    5: "länger als 5 Minuten",
    6: "länger als 6 Minuten",
    7: "länger als 7 Minuten",
    8: "länger als 8 Minuten",
    9: "länger als 9 Minuten",
    10: "länger als 10 Minuten",
    15: "länger als 15 Minuten",
    30: "länger als 30 Minuten",
    45: "länger als 45 Minuten",
    60: "länger als 1 Stunde",
    180: "länger als 3 Stunden"
  ]
  
  public static func interval(value: Int, from startDate: Date, calendar: Calendar = .current) -> DateInterval? {
    guard value != 0 else { return nil }
    let endDate = calendar.date(byAdding: .minute, value: value, to: startDate)!
    return .init(start: startDate, end: endDate)
  }
}

public struct Time {
  public let key: Int
  public let value: String

  public init(key: Int, value: String) {
    self.key = key
    self.value = value
  }
}
