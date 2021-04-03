// Created for weg-li in 2021.

import Foundation

@_functionBuilder
enum StringBuilder {
    static func buildBlock(_ strings: String...) -> String {
        strings.joined(separator: " ")
    }

    static func buildIf(_ part: String?) -> String {
        guard let string = part else { return "" }
        return string
    }
}

public extension String {
    init(@StringBuilder _ builder: () -> String) {
        self.init(builder())
    }
}
