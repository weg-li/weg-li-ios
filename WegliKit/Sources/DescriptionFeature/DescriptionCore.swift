// Created for weg-li in 2021.

import ComposableArchitecture
import FileClient
import Foundation
import Helper
import SharedModels
import SwiftUI

public struct DescriptionState: Equatable {
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
    self.selectedBrand = selectedBrand
    self.selectedDuration = selectedDuration
    self.selectedCharge = selectedCharge
    self.blockedOthers = blockedOthers
    self.vehicleEmpty = vehicleEmpty
    self.hazardLights = hazardLights
    self.expiredTuv = expiredTuv
    self.expiredEco = expiredEco
  }
  
  public var licensePlateNumber: String
  public var selectedColor: Int
  public var selectedBrand: CarBrand?
  public var selectedDuration: Int
  public var selectedCharge: Charge?
  @BindableState public var blockedOthers = false
  @BindableState public var vehicleEmpty = false
  @BindableState public var hazardLights = false
  @BindableState public var expiredTuv = false
  @BindableState public var expiredEco = false
  @BindableState public var note = ""
  
  public var chargeTypeSearchText = ""
  public var carBrandSearchText = ""
  
  public var presentChargeSelection = false
  public var presentCarBrandSelection = false
  
  public var charges: IdentifiedArrayOf<Charge> = []
  
  var carBrandSearchResults: IdentifiedArrayOf<CarBrand> {
    if carBrandSearchText.isEmpty {
      return Self.brands
    } else {
      return Self.brands.filter { $0.title.lowercased().contains(carBrandSearchText.lowercased()) }
    }
  }
  
  var chargesSearchResults: IdentifiedArrayOf<Charge> {
    if chargeTypeSearchText.isEmpty {
      return charges
    } else {
      return charges.filter { $0.text.lowercased().contains(chargeTypeSearchText.lowercased()) }
    }
  }
}

public enum DescriptionAction: BindableAction, Equatable {
  case binding(BindingAction<DescriptionState>)
  case onAppear
  case setLicensePlateNumber(String)
  case setBrand(CarBrand)
  case setColor(Int)
  case setCharge(Charge)
  case setDuraration(Int)
  case setChargeTypeSearchText(String)
  case setCarBrandSearchText(String)
  case toggleChargeFavorite(Charge)
  case sortFavoritedCharges
  case favoriteChargesLoaded(Result<[String], NSError>)
  case presentCargeSelectionView(Bool)
  case presentBrandSelectionView(Bool)
}

public struct DescriptionEnvironment {
  var mainQueue: AnySchedulerOf<DispatchQueue>
  var backgroundQueue: AnySchedulerOf<DispatchQueue>
  var fileClient: FileClient
  
  public init(
    mainQueue: AnySchedulerOf<DispatchQueue> = .main,
    backgroundQueue: AnySchedulerOf<DispatchQueue>,
    fileClient: FileClient = .live
  ) {
    self.mainQueue = mainQueue
    self.backgroundQueue = backgroundQueue
    self.fileClient = fileClient
  }
}

/// Reducer handing actions from EditDescriptionView.
public let descriptionReducer = Reducer<DescriptionState, DescriptionAction, DescriptionEnvironment> { state, action, environment in
  switch action {
  case .binding:
    return .none
      
  case .onAppear:
    return environment.fileClient.loadFavoriteCharges()
      .map(DescriptionAction.favoriteChargesLoaded)
    
  case let .setLicensePlateNumber(value):
    state.licensePlateNumber = value
    return .none
      
  case let .setBrand(value):
    state.selectedBrand = value
    state.presentCarBrandSelection = false
    return .none
      
  case let .setColor(value):
    state.selectedColor = value
    return .none
      
  case let .setCharge(value):
    state.selectedCharge = value
    state.presentChargeSelection = false
    return .none
      
  case let .setDuraration(value):
    state.selectedDuration = value
    return .none
      
  case let .setChargeTypeSearchText(query):
    state.chargeTypeSearchText = query
    return .none
      
  case let .setCarBrandSearchText(query):
    state.carBrandSearchText = query
    return .none
      
  case let .toggleChargeFavorite(charge):
    var charge = charge
    charge.isFavorite.toggle()
    charge.isSelected = charge.id == state.selectedCharge?.id
    guard let index = state.charges.firstIndex(where: { $0.id == charge.id }) else {
      return .none
    }
    state.charges.update(charge, at: index)
      
    struct FavoritedId: Hashable {}
    return .concatenate(
      environment.fileClient.saveFavoriteCharges(
        state.charges.filter(\.isFavorite).map(\.id),
        on: environment.backgroundQueue
      ).fireAndForget(),
      Effect(value: .sortFavoritedCharges)
        .delay(for: .seconds(0.7), scheduler: environment.mainQueue)
        .eraseToEffect()
    )
      
  case .sortFavoritedCharges:
    state.charges.sort { $0.isFavorite && !$1.isFavorite }
    return .none
      
  case let .favoriteChargesLoaded(result):
    let chargeIds = (try? result.get()) ?? []
      
    let charges = DescriptionState.charges.map {
      Charge(
        id: $0.key,
        text: $0.value,
        isFavorite: chargeIds.contains($0.key),
        isSelected: false
      )
    }
    state.charges = IdentifiedArrayOf(uniqueElements: charges, id: \.id)
      
    return Effect(value: .sortFavoritedCharges)
      
  case let .presentCargeSelectionView(value):
    state.chargeTypeSearchText = ""
    state.presentChargeSelection = value
    return .none
      
  case let .presentBrandSelectionView(value):
    state.carBrandSearchText = ""
    state.presentCarBrandSelection = value
    return .none
  }
}
.binding()

extension DescriptionState: Codable {}

public extension DescriptionState {
  var isValid: Bool {
    let arguments = [
      !licensePlateNumber.isEmpty,
      selectedColor != 0,
      selectedBrand != nil,
      selectedDuration != 0,
      selectedCharge != nil
    ]
    return arguments.allSatisfy { $0 == true }
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
  
  static let brands: IdentifiedArrayOf<CarBrand> = {
    let all = bundle.decode([String].self, from: "brands.json")
    let carBrands = all.map(CarBrand.init)
    return IdentifiedArray(uniqueElements: carBrands, id: \.id)
  }()
  
  var times: [Int] {
    Array(
      Times.times.sorted(by: { $0.0 < $1.0 })
        .map(\.key)
        .dropFirst()
    )
  }
  
  var time: String { Times.times[selectedDuration] ?? "" }
  
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
