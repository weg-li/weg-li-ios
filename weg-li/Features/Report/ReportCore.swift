//
//  ReportForm.swift
//  weg-li
//
//  Created by Stefan Trauth on 08.10.19.
//  Copyright © 2019 Stefan Trauth. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

// MARK: - Report Core
struct Report: Codable {
    var uuid = UUID()
    var storedPhotos: [StorableImage] = []
    var contact: ContactState
    var district: District?
    
    var date: Date = Date()
    var car = Car()
    var charge = Charge()
}

extension Report: Equatable {
    static func == (lhs: Report, rhs: Report) -> Bool {
        return lhs.contact == rhs.contact
            && lhs.district == rhs.district
            && lhs.car == rhs.car
            && lhs.charge == rhs.charge
        
    }
}

extension Report {
    struct Car: Equatable, Codable {
        var color: String = ""
        var type: String = ""
        var licensePlateNumber: String = ""
    }
    
    struct Charge: Equatable, Codable {
        var selectedDuration = 0
        var selectedType = 0
        var blockedOthers = false
        
        var time: String { Times.allCases[selectedDuration].description }
    }
}

extension Report {
    static var preview: Report {
        Report(
            uuid: UUID(),
            storedPhotos: [],
            contact: .preview,
            district: District(
                name: "Hamburg St. Pauli",
                zipCode: "20099",
                mail: "mail@stpauli.de"
            ),
            date: Date(),
            car: Car(
                color: "Gelb",
                type: "Kleinbus",
                licensePlateNumber: "HH-ST-PAULI"
            ),
            charge: Charge(
                selectedDuration: 0,
                selectedType: 0,
                blockedOthers: false
            )
        )
    }
    
    var isDescriptionValid: Bool {
        let isValid = ![car.type, car.color, car.licensePlateNumber]
            .map { $0.isEmpty }
            .contains(true)
        return isValid
    }
}

extension Report.Charge {
    static let charges = Bundle.main.decode([String].self, from: "charges.json")
    static let times = Times.allCases
}


enum ReportAction: Equatable {
    case addPhoto(UIImage)
    case removePhoto(index: Int)
    case contact(ContactAction)
    case car(CarAction)
    case charge(ChargeAction)
    case viewAppeared
}

struct ReportEnvironment {}

// MARK: - Car Core
enum CarAction: Equatable {
    case type(String)
    case color(String)
    case licensePlateNumber(String)
}

struct CarEnvironment {}

/// Reducer resposonsible for updating the car object
let carReducer = Reducer<Report.Car, CarAction, CarEnvironment> { state, action, _ in
    switch action {
    case let .type(value):
        state.type = value
        return .none
    case let .color(value):
        state.color = value
        return .none
    case let .licensePlateNumber(value):
        state.licensePlateNumber = value
        return .none
    }
}

// MARK: - Charge Core
enum ChargeAction: Equatable {
    case toggleBlockedOthers
    case selectCharge(Int)
    case selectDuraration(Int)
}

struct ChargeEnvironment {}

/// Reducer resposonsible for updating the charge object
let chargeReducer = Reducer<Report.Charge, ChargeAction, ChargeEnvironment> { state, action, _ in
    switch action {
    case .toggleBlockedOthers:
        state.blockedOthers.toggle()
        return .none
    case let .selectCharge(value):
        state.selectedType = value
        return .none
    case let .selectDuraration(value):
        state.selectedDuration = value
        return .none
    }
}

// MARK: - reportReducer

/// Combined reducer that is used in the ReportView
let reportReducer = Reducer<Report, ReportAction, ReportEnvironment>.combine(
    carReducer.pullback(
        state: \.car,
        action: /ReportAction.car,
        environment: { _ in CarEnvironment() }
    ),
    chargeReducer.pullback(
        state: \.charge,
        action: /ReportAction.charge,
        environment: { _ in ChargeEnvironment() }
    ),
    contactReducer.pullback(
        state: \.contact,
        action: /ReportAction.contact,
        environment: { _ in ContactEnvironment() }
    ),
    Reducer { state, action, environment in
        switch action {
        case let .addPhoto(photo):
            state.storedPhotos.append(StorableImage(uiImage: photo)!)
            return .none
        case let .removePhoto(index):
            state.storedPhotos.remove(at: index)
            return .none
        case .contact, .car, .charge:
            return .none
        case .viewAppeared:
            return Effect(value: ReportAction.contact(.isContactValid))
        }
    }
)
