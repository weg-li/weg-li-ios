// Created for weg-li in 2021.

import Foundation
import L10n

public enum Times: Int, CaseIterable {
  case empty = 0
  case one = 1
  case three = 3
  case five = 5
  case ten = 10
  case fifteen = 15
  case thirty = 30
  case fourtyfive = 45
  case sixty = 60
  case hundredEighty = 180
  
  public init?(rawValue: Int64) {
    switch rawValue {
    case 0:
      self = .empty
    case 1:
      self = .one
    case 3:
      self = .three
    case 5:
      self = .five
    case 10:
      self = .ten
    case 15:
      self = .fifteen
    case 30:
      self = .thirty
    case 60:
      self = .sixty
    case 180:
      self = .hundredEighty
    default:
      return nil
    }
  }
  
  public func interval(from startDate: Date, calendar: Calendar = .current) -> DateInterval? {
    switch self {
    case .empty, .one:
      return nil
    default:
      let endDate = calendar.date(byAdding: .minute, value: rawValue, to: startDate)!
      return .init(start: startDate, end: endDate)
    }
  }
  
  public var description: String {
    switch self {
    case .empty:
      return ""
    case .one:
      return L10n.Times.Description.upTo3
    default:
      return L10n.Times.Description.longerThenNMinutes(rawValue)
    }
  }
}
