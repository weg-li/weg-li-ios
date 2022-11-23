import Dependencies
import SharedModels
import XCTestDynamicOverlay

extension RegulatoryOfficeMapper: TestDependencyKey {
  public static let noop = Self(
    mapAddressToDistrict: { _ in .empty }
  )
  
  public static var testValue: RegulatoryOfficeMapper = Self(
    mapAddressToDistrict: unimplemented("\(Self.self).mapAddressToDistrict")
  )
}


extension District {
  static let empty = Self(name: "", zip: "", email: "", latitude: 0, longitude: 0, personalEmail: false)
}
