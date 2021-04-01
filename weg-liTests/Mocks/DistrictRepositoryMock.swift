//
//  DistrictRepositoryMock.swift
//  weg-liTests
//
//  Created by Malte on 01.04.21.
//  Copyright © 2021 Martin Wilhelmi. All rights reserved.
//

@testable import weg_li
import Combine
import CoreLocation

struct DistrictRepositoryMock: DistrictRepo {
    let districts: [District] = [.init(name: "Hamburg", zipCode: "20099", mail: "hh@hh.hh")]
}
