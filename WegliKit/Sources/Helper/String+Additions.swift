// Created for weg-li in 2021.

import Foundation

public extension String {
  var isNumeric: Bool {
    CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: self))
  }
}
