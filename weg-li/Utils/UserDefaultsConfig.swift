// Created for weg-li in 2021.

import Foundation

enum UserDefaultsConfig {
    @Storage(key: "contactData", defaultValue: .empty)
    static var contact: ContactState

    @Storage(key: "reports", defaultValue: [Report]())
    static var reports: [Report]

    @Storage(key: "draftReport", defaultValue: nil)
    static var draftReport: Report?
}
