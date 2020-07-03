//
//  Publicaffairsoffice.swift
//  weg-li
//
//  Created by Malte Bünz on 17.06.20.
//  Copyright © 2020 Stefan Trauth. All rights reserved.
//

import Foundation

struct Publicaffairsoffice: Decodable {
    let name: String
    let zipCode: String?
    let mail: String
    
    enum CodingKeys: String, CodingKey {
        case name = "ordnungsamt"
        case zipCode = "plz"
        case mail = "mail"
    }
    
    init(name: String, zipCode: String? = nil, mail: String) {
        self.name = name
        self.zipCode = zipCode
        self.mail = mail
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        if let value = try? container.decode(Int.self, forKey: .zipCode) {
            zipCode = String(value)
        } else {
            zipCode = try container.decode(String.self, forKey: .zipCode)
        }
        mail = try container.decode(String.self, forKey: .mail)
    }
}

extension Publicaffairsoffice {
    static let offices = Bundle.main.decode([Publicaffairsoffice].self, from: "publicaffairsoffice.json")
}
