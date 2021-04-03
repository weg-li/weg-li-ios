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
import ComposableCoreLocation

// MARK: - AppState
struct HomeState: Equatable {
    /// Users contact data. Persistet on the device
    private var _storedContact = ContactState()
    var contact: ContactState {
        get { _storedContact }
        set { _storedContact = newValue }
    }
    /// Reports a user has sent
    var reports: [Report] {
        get { UserDefaultsConfig.reports }
        set { UserDefaultsConfig.reports = newValue }
    }
    
    /// Holds a report that has not been stored or sent via mail
    private var _storedReport: Report?
    var reportDraft: Report {
        get {
            guard let report = _storedReport else {
                return Report(images: .init(), contact: contact)
            }
            return report
        }
        set {
            _storedReport = newValue
        }
    }
    
    var showReportWizard = false
}

// MARK: - AppAction
typealias Address = CNPostalAddress

enum HomeAction: Equatable {
    case contact(ContactAction)
    case report(ReportAction)
    case showReportWizard(Bool)
    case reportSaved
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
            environment: { _ in
                ReportEnvironment(
                    locationManager: LocationManager.live,
                    placeService: PlacesServiceImplementation(),
                    regulatoryOfficeMapper: RegulatoryOfficeMapper(districtsRepo: DistrictRepository())
                )
            }
    ),
    contactReducer.pullback(
        state: \.contact,
        action: /HomeAction.contact,
        environment: { _ in ContactEnvironment() }
    ),
    Reducer { state, action, environment in
        switch action {
        case let .contact(contact):
            state.reportDraft.contact = state.contact
            return .none
        case let .report(reportAction):
            if case let ReportAction.mail(.setMailResult(result)) = reportAction {
                guard let mailComposerResult = result else {
                    return .none
                }
                switch mailComposerResult {
                case .sent:
                    state.reports.append(state.reportDraft)
                    return Effect.concatenate(
                        Effect(value: HomeAction.showReportWizard(false))
                            .delay(for: 0.5, scheduler: environment.mainQueue)
                            .eraseToEffect(),
                        Effect(value: HomeAction.reportSaved)
                    )
                default:
                    return .none
                }
            }
            state.contact = state.reportDraft.contact
            return .none
        case let .showReportWizard(value):
            state.showReportWizard = value
            return .none
        case .reportSaved:
            state.reportDraft = Report(images: .init(), contact: state.contact)
            return .none
        }
    }
)
        
extension HomeState {
    static let preview = HomeState()
    
    init(reports: [Report]) {
        self.init()
        self.reports = reports
    }
}

struct NavigationError: Error {}
