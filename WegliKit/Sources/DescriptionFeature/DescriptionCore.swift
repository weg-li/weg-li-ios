// Created for weg-li in 2021.

import ComposableArchitecture
import FileClient
import Foundation
import Helper
import SharedModels
import SwiftUI

public struct DescriptionDomain: ReducerProtocol {
  public init() {}
  
  @Dependency(\.continuousClock) public var clock
  @Dependency(\.fileClient) public var fileClient
  
  public struct State: Equatable {
    public init(
      licensePlateNumber: String = "",
      selectedColor: Int = 0,
      selectedBrand: CarBrand? = nil,
      selectedDuration: Int = 0,
      selectedCharge: Charge? = nil,
      blockedOthers: Bool = false,
      vehicleEmpty: Bool = false,
      hazardLights: Bool = false,
      expiredTuv: Bool = false,
      expiredEco: Bool = false
    ) {
      self.licensePlateNumber = licensePlateNumber
      self.selectedColor = selectedColor
      self.carBrandSelection = .init(selectedBrand: selectedBrand)
      self.selectedDuration = selectedDuration
      self.chargeSelection = .init(selectedCharge: selectedCharge)
      self.blockedOthers = blockedOthers
      self.vehicleEmpty = vehicleEmpty
      self.hazardLights = hazardLights
      self.expiredTuv = expiredTuv
      self.expiredEco = expiredEco
    }
    
    public var carBrandSelection: CarBrandSelection.State
    public var chargeSelection: ChargeSelection.State

    @BindableState public var licensePlateNumber: String
    @BindableState public var selectedColor: Int
    @BindableState public var selectedDuration: Int
    @BindableState public var blockedOthers = false
    @BindableState public var vehicleEmpty = false
    @BindableState public var hazardLights = false
    @BindableState public var expiredTuv = false
    @BindableState public var expiredEco = false
    @BindableState public var note = ""
        
    @BindableState public var presentChargeSelection = false
    public var presentCarBrandSelection = false
    
    public var isValid: Bool {
      let arguments = [
        !licensePlateNumber.isEmpty,
        selectedColor != 0,
        carBrandSelection.selectedBrand != nil,
        selectedDuration != 0,
        chargeSelection.selectedCharge != nil
      ]
      return arguments.allSatisfy { $0 == true }
    }
  }
  
  public enum Action: BindableAction, Equatable {
    case binding(BindingAction<State>)
    case carBrandSelection(CarBrandSelection.Action)
    case chargeSelection(ChargeSelection.Action)
    
    case onAppear
    case favoriteChargesLoaded(TaskResult<[String]>)
    case presentChargeSelectionView(Bool)
    case presentBrandSelectionView(Bool)
  }
  
  public var body: some ReducerProtocol<State, Action> {
    BindingReducer()
    
    Scope(state: \.carBrandSelection, action: /Action.carBrandSelection) {
      CarBrandSelection()
    }
    
    Scope(state: \.chargeSelection, action: /Action.chargeSelection) {
      ChargeSelection()
    }
    
    Reduce<State, Action> { state, action in
      switch action {
      case .binding:
        return .none
          
      case .onAppear:
        return .task {
          await .favoriteChargesLoaded(
            TaskResult {
              try await fileClient.loadFavoriteCharges()
            }
          )
        }
        
      case let .favoriteChargesLoaded(result):
        let chargeIds = (try? result.value) ?? []
          
        let charges = Self.charges.map {
          Charge(
            id: $0.key,
            text: $0.value,
            isFavorite: chargeIds.contains($0.key),
            isSelected: false
          )
        }
        state.chargeSelection.charges = IdentifiedArrayOf(uniqueElements: charges, id: \.id)
        return EffectTask(value: .chargeSelection(.sortFavoritedCharges))
          
      case let .presentChargeSelectionView(value):
        state.chargeSelection.chargeTypeSearchText = ""
        state.presentChargeSelection = value
        return .none
          
      case let .presentBrandSelectionView(value):
        state.carBrandSelection.carBrandSearchText = ""
        state.presentCarBrandSelection = value
        return .none
        
      case .carBrandSelection(let carbrandSelectionAction):
        switch carbrandSelectionAction {
        case .setBrand:
          state.presentCarBrandSelection = false
          return .none
        case .binding:
          return .none
        }
        
      case .chargeSelection(let chargeSelectionAction):
        switch chargeSelectionAction {
        case .setCharge:
          state.presentChargeSelection = false
          return .none
        default:
          return .none
        }
      }
    }
  }
}

public extension DescriptionDomain {
  static let bundle = Bundle.module
  
  static let charges: [(key: String, value: String)] = {
    var all = bundle.decode([String: String].self, from: "charges.json")
      .compactMap { $0 }
      .sorted { $0.value < $1.value }
    return all
  }()
  
  static let colors: [(key: String, value: String)] = {
    var all = bundle.decode(
      [String: String].self, from: "colors.json",
      keyDecodingStrategy: .convertFromSnakeCase
    )
      .compactMap { $0 }
      .sorted { $0.value < $1.value }
    all.insert(("", ""), at: 0) // insert empty object for picker to start without initial selection
    return all
  }()
  
  static let brands: IdentifiedArrayOf<CarBrand> = {
    let all = bundle.decode([String].self, from: "brands.json")
    let carBrands = all.map(CarBrand.init)
    return IdentifiedArray(uniqueElements: carBrands, id: \.id)
  }()
}
 
public extension DescriptionDomain.State {
  var time: String { Times.times[selectedDuration] ?? "" }
  
  var times: [Int] {
    Array(
      Times.times.sorted(by: { $0.0 < $1.0 })
        .map(\.key)
        .dropFirst()
    )
  }
  
  func timeInterval(from startDate: Date) -> String {
    guard let interval = Times.interval(value: selectedDuration, from: startDate) else {
      return time
    }
    return "\(DateIntervalFormatter.reportTimeFormatter.string(from: interval)!) (\(time))"
  }
}

public struct CarBrand: Identifiable, Equatable, Codable {
  public var id: String = UUID().uuidString
  public let title: String

  public init(_ brand: String) {
    self.title = brand
  }
}
