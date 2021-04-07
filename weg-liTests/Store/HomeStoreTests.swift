// Created for weg-li in 2021.

import ComposableArchitecture
import MessageUI
@testable import weg_li
import XCTest

class HomeStoreTests: XCTestCase {
    let fixedUUID = { UUID() }
    let fixedDate = { Date() }
    let scheduler = DispatchQueue.test
    private var userDefaults: UserDefaults!
    
    override func setUp() {
        super.setUp()
        
        userDefaults = UserDefaults(suiteName: #file)
        userDefaults.removePersistentDomain(forName: #file)
    }
    
    func test_updateContact_ShouldUpdateState() {
        let store = TestStore(
            initialState: HomeState(),
            reducer: homeReducer,
            environment: HomeEnvironment(
                mainQueue: scheduler.eraseToAnyScheduler(),
                userDefaultsClient: .noop
            ))
        
        let newContact: ContactState = .preview
        
        store.assert(
            .send(.contact(.firstNameChanged(newContact.firstName))) {
                $0.contact.firstName = newContact.firstName
            },
            .receive(.contact(.isContactValid)))
    }
    
    func test_updateReport_ShouldUpdateState() {
        let store = TestStore(
            initialState: HomeState(),
            reducer: homeReducer,
            environment: HomeEnvironment(
                mainQueue: scheduler.eraseToAnyScheduler(),
                userDefaultsClient: .noop
            ))
        
        let newContact: ContactState = .preview
        
        store.assert(
            .send(.report(.contact(.firstNameChanged(newContact.firstName)))) {
                $0.contact.firstName = newContact.firstName
                $0.reportDraft.contact.firstName = newContact.firstName
            },
            .receive(.report(.contact(.isContactValid))))
    }
    
    func test_sentMailResult_shouldAppendDraftReportToReports() {
        let report = Report(
            uuid: fixedUUID(),
            images: ImagesViewState(
                showImagePicker: false,
                storedPhotos: [StorableImage(uiImage: UIImage(systemName: "pencil")!)!],
                resolvedLocation: .zero),
            contact: ContactState(),
            district: nil,
            date: fixedDate,
            description: .init(),
            location: .init(storedPhotos: []),
            mail: .init())
        
        let store = TestStore(
            initialState: HomeState(reportDraft: report),
            reducer: homeReducer,
            environment: HomeEnvironment(
                mainQueue: scheduler.eraseToAnyScheduler(),
                userDefaultsClient: .noop
            ))
        
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
            })
    }
    
    func test_contactStateShouldBeSaved_onContactViewDisappearAction() {
        let report = Report(
            uuid: fixedUUID(),
            images: ImagesViewState(
                showImagePicker: false,
                storedPhotos: [StorableImage(uiImage: UIImage(systemName: "pencil")!)!],
                resolvedLocation: .zero),
            contact: .preview,
            district: nil,
            date: fixedDate,
            description: .init(),
            location: .init(storedPhotos: []),
            mail: .init())
        
        let store = TestStore(
            initialState: HomeState(reportDraft: report),
            reducer: homeReducer,
            environment: HomeEnvironment(
                mainQueue: scheduler.eraseToAnyScheduler(),
                userDefaultsClient: .live(userDefaults: userDefaults)
            ))
        
        store.assert(
            .send(.contact(.firstNameChanged("Bob"))) {
                $0.contact.firstName = "Bob"
            },
            .receive(.contact(.isContactValid)) {
                $0.contact.isValid = false
            },
            .send(.contact(.onDisappear)) {
                $0.reportDraft.contact = $0.contact
                // check if contact has been saved to defaults
                XCTAssertEqual(store.environment.userDefaultsClient.contact, $0.contact)
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
