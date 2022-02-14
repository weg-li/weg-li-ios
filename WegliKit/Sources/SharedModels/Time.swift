// Created for weg-li in 2021.

import Foundation
import L10n

public enum Times: CaseIterable {
  case empty
  case one
  case three
  case five
  case ten
  case fifteen
  case thirty
  case fourtyfive
  case sixty
  case hundredEighty
  
  public var value: Int {
    switch self {
    case .empty: return 0
    case .one: return 1
    case .three: return 3
    case .five: return 5
    case .ten: return 10
    case .fifteen: return 15
    case .thirty: return 30
    case .fourtyfive: return 45
    case .sixty: return 60
    case .hundredEighty: return 180
    }
  }
  
  public var description: String {
    switch self {
    case .empty:
      return ""
    case .one:
      return L10n.Times.Description.upTo3
    case .three, .five, .ten, .fifteen, .thirty, .fourtyfive:
      return L10n.Times.Description.longerThenNMinutes(value)
    case .sixty:
      return L10n.Times.Description.longerThenNStunde(value)
    case .hundredEighty:
      return L10n.Times.Description.longerThenNStunden(value)
    }
  }
}
