// Created for weg-li in 2021.

import Combine
import ComposableArchitecture
import ComposableCoreLocation
import Contacts
import Foundation
import MapKit
import UIKit

// MARK: - AppState

struct HomeState: Equatable {
    /// Users contact data
    private var _storedContact = ContactState()
    var contact: ContactState {
        get { _storedContact }
        set { _storedContact = newValue }
    }

    /// Reports a user has sent
    var reports: [Report] = []

    /// Holds a report that has not been stored or sent via mail
    private var _storedReport: Report?
    var reportDraft: Report {
        get {
            guard let report = _storedReport else {
                return Report(images: .init(), contact: contact, date: Date.init)
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
    case onAppear
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
    var userDefaultsClient: UserDefaultsClient
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
                    regulatoryOfficeMapper: RegulatoryOfficeMapper(districtsRepo: DistrictRepository()))
            }),
    contactReducer.pullback(
        state: \.contact,
        action: /HomeAction.contact,
        environment: { _ in ContactEnvironment() }),
    Reducer { state, action, environment in
        switch action {
        // restore state from userdefaults
        case .onAppear:
            if let contact = environment.userDefaultsClient.contact {
                state.contact = contact
            }
            state.reports = environment.userDefaultsClient.reports
            return .none
        case let .contact(contactAction):
            switch contactAction {
            case .onDisappear:
                state.reportDraft.contact = state.contact
                return Effect.concatenate(
                    environment.userDefaultsClient.setContact(state.contact)
                        .fireAndForget(),
                    environment.userDefaultsClient.setReports([.preview])
                        .fireAndForget()
                )
            default:
                return .none
            }
        case let .report(reportAction):
            if case let ReportAction.mail(.setMailResult(result)) = reportAction {
                guard let mailComposerResult = result else {
                    return .none
                }
                switch mailComposerResult {
                case .sent:
                    state.reports.append(state.reportDraft)
                    
                    return Effect.concatenate(
                        environment.userDefaultsClient.setReports(state.reports)
                            .fireAndForget(),
                        Effect(value: HomeAction.showReportWizard(false))
                            .delay(for: 0.5, scheduler: environment.mainQueue)
                            .eraseToEffect(),
                        Effect(value: HomeAction.reportSaved))
                default:
                    return .none
                }
            }
            // sync contact with draftReport contact
            state.contact = state.reportDraft.contact
            return .none
        case let .showReportWizard(value):
            state.showReportWizard = value
            return .none
        case .reportSaved:
            state.reportDraft = Report(images: .init(), contact: state.contact, date: Date.init)
            return .none
        }
    })

extension HomeState {
    static let preview = HomeState()

    // init for previews
    init(reports: [Report]) {
        self.init()
        self.reports = reports
    }
}
