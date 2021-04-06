//
//  Codable+Sugar.swift
//  weg-li
//
//  Created by Malte on 05.04.21.
//  Copyright © 2021 Martin Wilhelmi. All rights reserved.
//

import Foundation

extension Data {
    func decoded<T: Decodable>(decoder: JSONDecoder = JSONDecoder()) throws -> T {
        try decoder.decode(T.self, from: self)
    }
}

extension Encodable {
    func encoded(encoder: JSONEncoder = JSONEncoder()) throws -> Data {
        try encoder.encode(self)
    }
}
