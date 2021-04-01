//
//  File.swift
//  weg-li
//
//  Created by Malte on 01.04.21.
//  Copyright © 2021 Martin Wilhelmi. All rights reserved.
//

import Foundation

struct RegulatoryOfficeMapper {
    let districtsRepo: DistrictRepo
    
    func mapAddressToDistrict(_ address: GeoAddress) -> District? {
        let district = districtsRepo.districts.first(where: { $0.name == address.city })
        guard district != nil else {
            return nil
        }
        return district
    }
}
