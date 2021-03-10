//
//  DateFormatter+Additions.swift
//  weg-li
//
//  Created by Malte Bünz on 18.06.20.
//  Copyright © 2020 Stefan Trauth. All rights reserved.
//

import Foundation

extension DateFormatter {
    static let dateFormatterMediumStyles: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .medium
        return formatter
    }()
}

extension Date {
    var humandReadableDate: String {
        DateFormatter.dateFormatterMediumStyles.string(from: self)
    }
}
