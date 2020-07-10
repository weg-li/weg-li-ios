//
//  PublicAffairsOfficeMather.swift
//  weg-li
//
//  Created by Malte Bünz on 17.06.20.
//  Copyright © 2020 Stefan Trauth. All rights reserved.
//

import Combine
import Foundation

final class PublicAffairsOfficeMatcher {
    private let offices = District.offices
    
    func mapAddressToAffairsOffice(_ address: Address) -> AnyPublisher<District?, Never> {
        let office = offices.first(where: { $0.name == address.city })
        guard office != nil else {
            return Just(nil).eraseToAnyPublisher()
        }
        return Just(office).eraseToAnyPublisher()
    }
}
