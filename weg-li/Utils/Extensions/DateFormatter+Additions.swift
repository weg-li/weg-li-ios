// Created for weg-li in 2021.

import Foundation

extension DateFormatter {
    static let dateFormatterMediumStyles: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateStyle = .medium
        return formatter
    }()
}

extension Date {
    var humandReadableDate: String {
        DateFormatter.dateFormatterMediumStyles.string(from: self)
    }
}
