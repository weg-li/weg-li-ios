// Created for weg-li in 2021.

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
