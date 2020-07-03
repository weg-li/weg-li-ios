//
//  String+Builder.swift
//  weg-li
//
//  Created by Malte Bünz on 09.06.20.
//  Copyright © 2020 Stefan Trauth. All rights reserved.
//

import Foundation

@_functionBuilder
struct StringBuilder {
    static func buildBlock(_ strings: String...) -> String {
        strings.joined(separator: " ")
    }
    
    static func buildIf(_ part: String?) -> String {
        guard let string = part else { return "" }
        return string
    }
}

extension String {
    public init(@StringBuilder _ builder: () -> String) {
        self.init(builder())
    }
}
