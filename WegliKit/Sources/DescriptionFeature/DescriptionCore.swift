// Created for weg-li in 2021.

import ComposableArchitecture
import Foundation
import Helper
import SharedModels
import SwiftUI
import FileClient

public struct DescriptionState: Equatable {
  public init(
    licensePlateNumber: String = "",
    selectedColor: Int = 0,
    selectedBrand: Int = 0,
    selectedDuration: Int = 0,
    selectedCharge: Charge? = nil,
    blockedOthers: Bool = false
  ) {
    self.licensePlateNumber = licensePlateNumber
    self.selectedColor = selectedColor
    self.selectedBrand = selectedBrand
    self.selectedDuration = selectedDuration
    self.selectedCharge = selectedCharge
    self.blockedOthers = blockedOthers
  }
  
  public var licensePlateNumber: String
  public var selectedColor: Int
  public var selectedBrand: Int
  public var selectedDuration: Int
  public var selectedCharge: Charge?
  public var blockedOthers: Bool
  public var chargeTypeSearchText = ""
  
  public var charges: IdentifiedArrayOf<Charge> = []
  
  var searchResults: IdentifiedArrayOf<Charge> {
      if chargeTypeSearchText.isEmpty {
        return charges
      } else {
        return charges.filter { $0.text.lowercased().contains(chargeTypeSearchText.lowercased()) }
      }
    }
}

public enum DescriptionAction: Equatable {
  case onAppear
  case setLicensePlateNumber(String)
  case setBrand(Int)
  case setColor(Int)
  case toggleBlockedOthers
  case setCharge(Charge)
  case setDuraration(Int)
  case setChargeTypeSearchText(String)
  case toggleChargeFavorite(Charge)
  case sortFavoritedCharges
  case favoriteChargesLoaded(Result<[String], NSError>)
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
    case .onAppear:
      return environment.fileClient.loadFavoriteCharges()
        .map(DescriptionAction.favoriteChargesLoaded)
    
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
      state.selectedCharge = value
      return .none
      
    case let .setDuraration(value):
      state.selectedDuration = value
      return .none
      
    case let .setChargeTypeSearchText(query):
      state.chargeTypeSearchText = query
      return .none
      
    case let .toggleChargeFavorite(charge):
      var charge = charge
      charge.isFavorite.toggle()
      guard let index = state.charges.firstIndex(where: { $0.id == charge.id }) else {
        return .none
      }
      state.charges.update(charge, at: index)
      
      struct FavoritedId: Hashable {}
      return .merge(
        Effect(value: .sortFavoritedCharges)
          .debounce(id: FavoritedId(), for: 1, scheduler: environment.mainQueue),
        environment.fileClient.saveFavoriteCharges(
          state.charges.filter(\.isFavorite).map(\.id),
          on: environment.backgroundQueue
        ).fireAndForget()
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
    }
}

extension DescriptionState: Codable {}

public extension DescriptionState {
  var isValid: Bool {
    let arguments = [
      !licensePlateNumber.isEmpty,
      selectedColor != 0,
      selectedBrand != 0,
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
  
  static let brands: [String] = {
    var all = bundle.decode([String].self, from: "brands.json")
    all.insert("", at: 0) // insert empty object for picker to start without initial selection
    return all
  }()
  
  static let times = Times.allCases
  
  var time: String { Times.allCases[selectedDuration].description }
  
  func timeInterval(from startDate: Date) -> String {
    guard let interval = Times.allCases[selectedDuration].interval(from: startDate) else {
      return time
    }
    return "\(time) - \(DateIntervalFormatter.reportTimeFormatter.string(from: interval)!)"  
  }
}
