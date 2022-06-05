// Created for weg-li in 2021.

import Combine
import ComposableArchitecture
import ComposableCoreLocation
import MapKit
import RegulatoryOfficeMapper
import SharedModels
import XCTest

class OfficeMapperTests: XCTestCase {
  var sut: RegulatoryOfficeMapper!
  
  private var bag = Set<AnyCancellable>()
  let districts = DistrictFixtures.districts
  
  override func setUp() {
    super.setUp()
    sut = .live(districts)
  }
  
  func test_loadAllDistricts_performance() {
    measure {
      _ = [District].all
    }
  }
  
  func test_officeMappingByPostalCode() {
    let address = Address(
      street: "TestStrasse 3",
      postalCode: "10629",
      city: "Berlin"
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
    let address = Address(
      street: "TestStrasse 3",
      postalCode: "12345",
      city: "Berlin"
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
    let address = Address(
      street: "TestStrasse 3",
      postalCode: "00001",
      city: "Rendsburg"
    )
    
    Effect(sut.mapAddressToDistrict(address))
      .upstream
      .sink(
        receiveCompletion: { completion in
          if case let .failure(error) = completion {
            XCTAssertEqual(error, .unableToMatchRegularityOffice)
          }
        },
        receiveValue: { _ in
          XCTFail()
        }
      )
      .store(in: &bag)
  }
}
