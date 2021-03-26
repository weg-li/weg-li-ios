//
//  weg-li
//
//  Created by Malte Bünz on 17.06.20.
//  Copyright © 2020 Stefan Trauth. All rights reserved.
//

import Combine
import Foundation

struct District: Equatable, Codable {
    let name: String
    let zipCode: String
    let mail: String
    
    enum CodingKeys: String, CodingKey {
        case name = "ordnungsamt"
        case zipCode = "plz"
        case mail = "mail"
    }
    
    init(name: String, zipCode: String, mail: String) {
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

extension District {
    static let districts = Bundle.main.decode([District].self, from: "districts.json")
    
    static func mapAddressToDistrict(_ address: Address) -> AnyPublisher<District?, Never> {
        let district = districts.first(where: { $0.name == address.city })
        guard district != nil else {
            return Just(nil).eraseToAnyPublisher()
        }
        return Just(district).eraseToAnyPublisher()
    }
}
