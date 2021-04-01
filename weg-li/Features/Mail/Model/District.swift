//
//  weg-li
//
//  Created by Malte Bünz on 17.06.20.
//  Copyright © 2020 Stefan Trauth. All rights reserved.
//

import Combine
import Foundation

struct District: Equatable {
    var name: String = ""
    var zipCode: String = ""
    var mail: String = ""
}
 
extension District: Codable {
    enum CodingKeys: String, CodingKey {
        case name = "ordnungsamt"
        case zipCode = "plz"
        case mail = "mail"
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
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(zipCode, forKey: .zipCode)
        try container.encode(mail, forKey: .mail)
    }
}
