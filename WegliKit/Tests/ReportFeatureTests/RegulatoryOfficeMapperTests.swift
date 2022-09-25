// Created for weg-li in 2021.

import Combine
import ComposableArchitecture
import ComposableCoreLocation
import MapKit
import RegulatoryOfficeMapper
import SharedModels
import XCTest

final class OfficeMapperTests: XCTestCase {
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
  
  func test_officeMappingByPostalCode() async throws {
    let address = Address(
      street: "TestStrasse 3",
      postalCode: "10629",
      city: "Berlin"
    )
    
    let district = try await sut.mapAddressToDistrict(address)
    
    XCTAssertEqual(district, self.districts[0])
  }
  
  func test_officeMappingByCityName() async throws {
    let address = Address(
      street: "TestStrasse 3",
      postalCode: "12345",
      city: "Berlin"
    )
    
    let district = try await sut.mapAddressToDistrict(address)
    
    XCTAssertEqual(district, self.districts[0])
  }
  
  func test_officeMappingByCityName_shouldFail_whenPostalCodeAndCityName() async throws {
    let address = Address(
      street: "TestStrasse 3",
      postalCode: "00001",
      city: "Rendsburg"
    )
    
    do {
      let _ = try await sut.mapAddressToDistrict(address)
      XCTFail()
    } catch {
      print("Test succeded")
    }
  }
}
