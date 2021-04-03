// Created for weg-li in 2021.

import Foundation

protocol DistrictRepo {
    var districts: [District] { get }
}

struct DistrictRepository: DistrictRepo {
    let districts = Bundle.main.decode([District].self, from: "districts.json")
}
