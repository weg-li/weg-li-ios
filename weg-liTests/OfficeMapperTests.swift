// Created for weg-li in 2021.

import Combine
import ComposableArchitecture
import ComposableCoreLocation
import MapKit
@testable import weg_li
import XCTest

class OfficeMapperTests: XCTestCase {
    var sut: RegulatoryOfficeMapper!

    let districts = [
        District(name: "Berlin", zipCode: "10629", mail: "Anzeige@bowi.berlin.de"),
        District(name: "Dortmund", zipCode: "44287", mail: "fremdanzeigen.verkehrsueberwachung@stadtdo.de")
    ]
    private var bag = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()
        sut = .live(districts)
    }

    func test_officeMappingByPostalCode() {
        let address = GeoAddress(
            street: "TestStrasse 3",
            city: "Berlin",
            postalCode: "10629"
        )

        Effect(sut.mapAddressToDistrict(address))
            .upstream
            .sink(
                receiveCompletion: { completion in
                    if case .failure = completion {
                        XCTFail()
                    }
                },
                receiveValue: { value in
                    XCTAssertEqual(value, self.districts[0])
                }
            )
            .store(in: &bag)
    }

    func test_officeMappingByCityName() {
        let address = GeoAddress(
            street: "TestStrasse 3",
            city: "Berlin",
            postalCode: "12345"
        )

        Effect(sut.mapAddressToDistrict(address))
            .upstream
            .sink(
                receiveCompletion: { completion in
                    if case .failure = completion {
                        XCTFail()
                    }
                },
                receiveValue: { value in
                    XCTAssertEqual(value, self.districts[0])
                }
            )
            .store(in: &bag)
    }

    func test_officeMappingByCityName_shouldFail_whenPostalCodeAndCityName() {
        let address = GeoAddress(
            street: "TestStrasse 3",
            city: "Rendsburg",
            postalCode: "00001"
        )

        Effect(sut.mapAddressToDistrict(address))
            .upstream
            .sink(
                receiveCompletion: { completion in
                    if case let .failure(error) = completion {
                        XCTAssertEqual(error, .unableToMatchRegularityOffice)
                    }
                },
                receiveValue: { value in
                    XCTFail()
                }
            )
            .store(in: &bag)
    }
}
