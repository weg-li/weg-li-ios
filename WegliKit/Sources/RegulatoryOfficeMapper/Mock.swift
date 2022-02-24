import ComposableArchitecture

public extension RegulatoryOfficeMapper {
  static let noop = Self(
    mapAddressToDistrict: { _ in .none }
  )
}
