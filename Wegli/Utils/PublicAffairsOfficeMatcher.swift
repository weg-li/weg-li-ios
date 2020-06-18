//
//  PublicAffairsOfficeMather.swift
//  Wegli
//
//  Created by Malte Bünz on 17.06.20.
//  Copyright © 2020 Stefan Trauth. All rights reserved.
//

import Combine
import Foundation

final class PublicAffairsOfficeMatcher {
    private let offices = Publicaffairsoffice.offices
    
    func mapAddressToAffairsOffice(_ address: Address) -> AnyPublisher<Publicaffairsoffice?, Never> {
        let office = offices.first(where: { $0.name == address.city })
        guard office != nil else {
            return Just(nil).eraseToAnyPublisher()
        }
        return Just(office).eraseToAnyPublisher()
    }
}
