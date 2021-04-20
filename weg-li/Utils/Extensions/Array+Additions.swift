// Created for weg-li in 2021.

import Foundation

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}

extension Array where Element == District {
    static let all = Bundle.main.decode(
        [District].self, from: "districts.json",
        dateDecodingStrategy: .iso8601,
        keyDecodingStrategy: .convertFromSnakeCase
    )
}
