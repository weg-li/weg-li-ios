// Created for weg-li in 2021.

import ComposableArchitecture
import Foundation
import Helper
import SharedModels

public struct DescriptionState: Equatable {
  public init(
    licensePlateNumber: String = "",
    selectedColor: Int = 0,
    selectedBrand: Int = 0,
    selectedDuration: Int = 0,
    selectedType: Int = 0,
    blockedOthers: Bool = false
  ) {
    self.licensePlateNumber = licensePlateNumber
    self.selectedColor = selectedColor
    self.selectedBrand = selectedBrand
    self.selectedDuration = selectedDuration
    self.selectedType = selectedType
    self.blockedOthers = blockedOthers
  }
  
  public var licensePlateNumber: String
  public var selectedColor: Int
  public var selectedBrand: Int
  public var selectedDuration: Int
  public var selectedType: Int
  public var blockedOthers: Bool
}

public enum DescriptionAction: Equatable {
  case setLicensePlateNumber(String)
  case setBrand(Int)
  case setColor(Int)
  case toggleBlockedOthers
  case setCharge(Int)
  case setDuraration(Int)
}

public struct DescriptionEnvironment {
  public init() {}
}

/// Reducer handing actions from EditDescriptionView.
public let descriptionReducer = Reducer<DescriptionState, DescriptionAction, DescriptionEnvironment> { state, action, _ in
  switch action {
  case let .setLicensePlateNumber(value):
    state.licensePlateNumber = value
    return .none
  case let .setBrand(value):
    state.selectedBrand = value
    return .none
  case let .setColor(value):
    state.selectedColor = value
    return .none
  case .toggleBlockedOthers:
    state.blockedOthers.toggle()
    return .none
  case let .setCharge(value):
    state.selectedType = value
    return .none
  case let .setDuraration(value):
    state.selectedDuration = value
    return .none
  }
}

extension DescriptionState: Codable {}

public extension DescriptionState {
  var isValid: Bool {
    !licensePlateNumber.isEmpty
  }
}

public extension DescriptionState {
  static let bundle = Bundle.module
  
  static let charges: [(key: String, value: String)] = {
    var all = bundle.decode([String: String].self, from: "charges.json")
      .compactMap { $0 }
      .sorted { a, b -> Bool in
        a.value < b.value
      }
    all.insert(("", ""), at: 0) // insert empty object for picker to start without initial selection
    return all
  }()
  
  static let colors: [(key: String, value: String)] = {
    var all = bundle.decode(
      [String: String].self, from: "colors.json",
      keyDecodingStrategy: .convertFromSnakeCase
    )
      .compactMap { $0 }
      .sorted { a, b -> Bool in
        a.value < b.value
      }
    all.insert(("", ""), at: 0) // insert empty object for picker to start without initial selection
    return all
  }()
  
  static let brands: [String] = {
    var all = bundle.decode([String].self, from: "brands.json")
    all.insert("", at: 0) // insert empty object for picker to start without initial selection
    return all
  }()
  
  static let times = Times.allCases
  
  var time: String { Times.allCases[selectedDuration].description }
}
