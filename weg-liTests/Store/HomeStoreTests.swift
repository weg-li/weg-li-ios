//
//  AppStoreTests.swift
//  weg-liTests
//
//  Created by Malte on 25.03.21.
//  Copyright © 2021 Martin Wilhelmi. All rights reserved.
//

@testable import weg_li
import ComposableArchitecture
import MessageUI
import XCTest

class HomeStoreTests: XCTestCase {
    let fixedUUID = { UUID() }
    let fixedDate = { Date() }
    let scheduler = DispatchQueue.testScheduler

    func test_updateContact_ShouldUpdateState() {
        let store = TestStore(
            initialState: HomeState(),
            reducer: homeReducer,
            environment: HomeEnvironment(
                mainQueue: scheduler.eraseToAnyScheduler()
            )
        )
        
        let newContact: ContactState = .preview
        
        store.assert(
            .send(.contact(.firstNameChanged(newContact.firstName))) {
                $0.contact.firstName = newContact.firstName
                $0.reportDraft.contact.firstName = newContact.firstName
            },
            .receive(.contact(.isContactValid))
        )
    }
    
    func test_updateReport_ShouldUpdateState() {
        let store = TestStore(
            initialState: HomeState(),
            reducer: homeReducer,
            environment: HomeEnvironment(
                mainQueue: scheduler.eraseToAnyScheduler()
            )
        )
        
        let newContact: ContactState = .preview
        
        store.assert(
            .send(.report(.contact(.firstNameChanged(newContact.firstName)))) {
                $0.contact.firstName = newContact.firstName
                $0.reportDraft.contact.firstName = newContact.firstName
            },
            .receive(.report(.contact(.isContactValid)))
        )
    }
    
    func test_sentMailResult_shouldAppendDraftReportToReports() {
        let report = Report(
            uuid: fixedUUID(),
            images: ImagesViewState(
                showImagePicker: false,
                storedPhotos: [StorableImage(uiImage: UIImage(systemName: "pencil")!)!],
                resolvedLocation: nil
            ),
            contact: ContactState(),
            district: nil,
            date: fixedDate(),
            car: .init(
                color: "Red",
                type: "Big Car",
                licensePlateNumber: "MIT"
            ),
            charge: .init(),
            location: .init(storedPhotos: []),
            mail: .init()
        )
        
        let store = TestStore(
            initialState: HomeState(reportDraft: report),
            reducer: homeReducer,
            environment: HomeEnvironment(mainQueue: scheduler.eraseToAnyScheduler()
            )
        )
        
        store.assert(
            .send(.report(.mail(.setMailResult(MFMailComposeResult(rawValue: 2))))) {
                $0.reports = [report]
            },
            .do { self.scheduler.advance(by: 1) },
            .receive(.showReportWizard(false)) {
                $0.showReportWizard = false
            },
            .receive(.reportSaved) {
                $0.reportDraft = Report(images: .init(), contact: .init())
            }
        )
    }
}

private extension HomeState {
    init(reportDraft: Report) {
        self.init()
        self.reportDraft = reportDraft
    }
}
