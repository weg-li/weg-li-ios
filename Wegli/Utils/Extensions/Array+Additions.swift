//
//  Array+Additions.swift
//  Wegli
//
//  Created by Malte Bünz on 14.06.20.
//  Copyright © 2020 Stefan Trauth. All rights reserved.
//

import Foundation

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
