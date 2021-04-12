// Created for weg-li in 2021.

import Foundation

extension DateFormatter {
    static let dateFormatterWithoutTimeMediumStyle: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateStyle = .medium
        return formatter
    }()

    static let dateFormatterWithoutDateMediumStyle: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .long
        formatter.dateStyle = .none
        return formatter
    }()
}

extension Date {
    var humandReadableDate: String {
        DateFormatter.dateFormatterWithoutTimeMediumStyle.string(from: self)
    }

    var humandReadableTime: String {
        DateFormatter.dateFormatterWithoutDateMediumStyle.string(from: self)
    }
}
