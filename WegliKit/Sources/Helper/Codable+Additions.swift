// Created for weg-li in 2021.

import Foundation

public extension Data {
  func decoded<T: Decodable>(decoder: JSONDecoder = JSONDecoder()) throws -> T {
    try decoder.decode(T.self, from: self)
  }
}

public extension Encodable {
  func encoded(encoder: JSONEncoder = JSONEncoder()) throws -> Data {
    try encoder.encode(self)
  }
}
