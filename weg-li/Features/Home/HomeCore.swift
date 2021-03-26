//
//  AppState.swift
//  weg-li
//
//  Created by Malte Bünz on 08.06.20.
//  Copyright © 2020 Stefan Trauth. All rights reserved.
//

import Combine
import Contacts
import Foundation
import MapKit
import UIKit
import ComposableArchitecture

// MARK: - AppState
struct HomeState: Equatable {
    /// Users contact data. Persistet on the device
    var storedContact: ContactState = ContactState()
    var contact: ContactState {
        get { storedContact }
        set { storedContact = newValue }
    }
    /// Reports a user has sent
    var reports: [Report] {
        get { UserDefaultsConfig.reports }
        set { UserDefaultsConfig.reports = newValue }
    }
    
    /// Holds a report that has not been stored or sent via mail
    var reportDraft: Report {
        get {
            guard let report = UserDefaultsConfig.draftReport else {
                return Report(contact: contact)
            }
            return report
        }
        set {
            UserDefaultsConfig.draftReport = newValue
        }
    }
    var location: LocationState? = LocationState()
}

extension HomeState {
    struct LocationState: Equatable {
        var isAuthorized: Bool = false
        var userDefinedLocation: CLLocationCoordinate2D?
        var location: CLLocationCoordinate2D = CLLocationCoordinate2D()
        var presumedAddress: Address?
    }
}

// MARK: - AppAction
typealias Address = CNPostalAddress

enum HomeAction: Equatable {
    case contact(ContactAction)
    case report(ReportAction)
}

// MARK: Location

// MARK: Description
extension HomeAction {
    enum DescriptionAction {
        case setCar(Report.Car)
        case setCharge(Report.Charge)
        case resolveDistrict(Address)
        case setDistrict(District)
    }
}

// MARK: - Environment
struct HomeEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
}

let homeReducer = Reducer<HomeState, HomeAction, HomeEnvironment>.combine(
    reportReducer
        .pullback(
            state: \.reportDraft,
            action: /HomeAction.report,
            environment: { _ in ReportEnvironment() }
    ),
    contactReducer.pullback(
        state: \.contact,
        action: /HomeAction.contact,
        environment: { _ in ContactEnvironment() }
    ),
    Reducer { state, action, env in
        switch action {
        case let .contact(contact):
            state.reportDraft.contact = state.contact
            return .none
        case let .report(reportAction):
            state.contact = state.reportDraft.contact
            return .none
        }
    }
)
        


extension HomeState {
    static let preview = HomeState(
        location: LocationState()
    )
}
