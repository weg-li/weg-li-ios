//
//  DateFormatter+Additions.swift
//  Wegli
//
//  Created by Malte Bünz on 18.06.20.
//  Copyright © 2020 Stefan Trauth. All rights reserved.
//

import Foundation

extension Date {
    var humandReadableDate: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .medium
        return formatter.string(from: self)
    }
}
