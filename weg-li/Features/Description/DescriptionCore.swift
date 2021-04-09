// Created for weg-li in 2021.

import ComposableArchitecture
import Foundation

struct DescriptionState: Equatable {
    var color: String = ""
    var type: String = ""
    var licensePlateNumber: String = ""
    var selectedDuration = 0
    var selectedType = 0
    var blockedOthers = false
}

enum DescriptionAction: Equatable {
    case setType(String)
    case setColor(String)
    case setLicensePlateNumber(String)
    case toggleBlockedOthers
    case setCharge(Int)
    case setDuraration(Int)
}

struct DescriptionEnvironment {}

// MARK: Reducer

let descriptionReducer = Reducer<DescriptionState, DescriptionAction, DescriptionEnvironment> { state, action, _ in
    switch action {
    case let .setType(value):
        state.type = value
        return .none
    case let .setColor(value):
        state.color = value
        return .none
    case let .setLicensePlateNumber(value):
        state.licensePlateNumber = value
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

extension DescriptionState {
    var isValid: Bool {
        [
            type,
            color,
            licensePlateNumber
        ]
        .allSatisfy { !$0.isEmpty }
    }
}

extension DescriptionState {
    static let charges = Bundle.main.decode([String].self, from: "charges.json")
    static let times = Times.allCases

    var time: String { Times.allCases[selectedDuration].description }
}
