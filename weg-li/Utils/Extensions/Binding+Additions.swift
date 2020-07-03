//
//  Binding+Additions.swift
//  weg-li
//
//  Created by Malte Bünz on 09.06.20.
//  Copyright © 2020 Stefan Trauth. All rights reserved.
//

import SwiftUI

extension Binding {
    func onChange(_ handler: @escaping (Value) -> Void) -> Binding<Value> {
        return Binding(
            get: { self.wrappedValue },
            set: { selection in
                self.wrappedValue = selection
                handler(selection)
        })
    }
}
