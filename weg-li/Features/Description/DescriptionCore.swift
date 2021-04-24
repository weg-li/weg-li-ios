// Created for weg-li in 2021.

import ComposableArchitecture
import Foundation

struct DescriptionState: Equatable {
    var licensePlateNumber: String = ""
    var selectedColor = 0
    var selectedBrand = 0
    var selectedDuration = 0
    var selectedType = 0
    var blockedOthers = false
}

enum DescriptionAction: Equatable {
    case setLicensePlateNumber(String)
    case setBrand(Int)
    case setColor(Int)
    case toggleBlockedOthers
    case setCharge(Int)
    case setDuraration(Int)
}

struct DescriptionEnvironment {}

/// Reducer handing actions from EditDescriptionView.
let descriptionReducer = Reducer<DescriptionState, DescriptionAction, DescriptionEnvironment> { state, action, _ in
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

extension DescriptionState {
    var isValid: Bool {
        !licensePlateNumber.isEmpty
    }
}

extension DescriptionState {
    static let charges: [(key: String, value: String)] = {
        var all = Bundle.main.decode([String: String].self, from: "charges.json")
            .compactMap { $0 }
            .sorted { a, b -> Bool in
                a.value < b.value
            }
        all.insert(("", ""), at: 0) // insert empty object for picker to start without initial selection
        return all
    }()

    static let colors: [(key: String, value: String)] = {
        var all = Bundle.main.decode(
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
        var all = Bundle.main.decode([String].self, from: "brands.json")
        all.insert("", at: 0) // insert empty object for picker to start without initial selection
        return all
    }()

    static let times = Times.allCases

    var time: String { Times.allCases[selectedDuration].description }
}
