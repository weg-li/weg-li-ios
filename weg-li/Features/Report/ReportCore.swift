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
        return lhs.uuid == rhs.uuid
    }
}

extension Report {
    // MARK: Description
    struct Car: Equatable, Codable {
        var color: String?
        var type: String?
        var licensePlateNumber: String?
    }
    
    struct Charge: Equatable, Codable {
        var selectedDuration = 0
        var selectedType = 0
        var blockedOthers = false
        
        var humandReadableCharge: String { Charge.charges[selectedType] }
        var time: String { Times.allCases[selectedDuration].description }
    }
}

extension Report {
    var isDescriptionValid: Bool {
        guard let type = car.type, let color = car.color, let plate = car.licensePlateNumber else {
            return false
        }
        let isValid = ![type, color, plate]
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
    case viewAppeared
}

struct ReportEnvironment {
    let imageDataStore: ImageDataStore
}

let reportReducer = Reducer<Report, ReportAction, ReportEnvironment>{ state, action, environment in
    switch action {
    case let .addPhoto(photo):
        state.storedPhotos.append(StorableImage(uiImage: photo)!)
        return .none
    case let .removePhoto(index):
        state.storedPhotos.remove(at: index)
        return .none
    case .contact:
        return .none
    case .viewAppeared:
        return Effect(value: ReportAction.contact(.isContactValid))
    }
}.combined(
    with: contactReducer.pullback(
        state: \.contact,
        action: /ReportAction.contact,
        environment: { _ in ContactEnvironment() }
    )
)
