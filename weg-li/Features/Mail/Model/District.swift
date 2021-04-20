// Created for weg-li in 2021.

import Combine
import Foundation

struct District: Equatable, Codable {
    let name: String
    let zip: String
    let email: String
    let latitude: Double
    let longitude: Double
    let personalEmail: Bool
}
