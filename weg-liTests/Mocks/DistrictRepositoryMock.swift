// Created for weg-li in 2021.

import Combine
import CoreLocation
@testable import weg_li

struct DistrictRepositoryMock: DistrictRepo {
    let districts: [District] = [.init(name: "Hamburg", zipCode: "20099", mail: "hh@hh.hh")]
}
