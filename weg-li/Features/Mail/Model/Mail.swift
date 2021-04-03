// Created for weg-li in 2021.

import Foundation

struct Mail: Equatable, Codable {
    var address: String = ""
    var subject: String = "Anzeige mit der Bitte um Weiterverfolgung"
    var body: String = ""
    var attachmentData: [Data] = []
}
