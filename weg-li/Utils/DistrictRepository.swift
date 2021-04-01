//
//  DistrictRepository.swift
//  weg-li
//
//  Created by Malte on 01.04.21.
//  Copyright © 2021 Martin Wilhelmi. All rights reserved.
//

import Foundation

protocol DistrictRepo {
    var districts: [District] { get }
}

struct DistrictRepository: DistrictRepo {
    let districts = Bundle.main.decode([District].self, from: "districts.json")
}
