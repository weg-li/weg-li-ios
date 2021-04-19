// Created for weg-li in 2021.

import ComposableArchitecture
import MessageUI
@testable import weg_li
import XCTest

class HomeStoreTests: XCTestCase {
    let fixedUUID = { UUID() }
    let fixedDate = { Date() }
    let scheduler = DispatchQueue.immediate.eraseToAnyScheduler()
    private var userDefaults: UserDefaults!

    private var report: Report!

    override func setUp() {
        super.setUp()

        report = Report(
            uuid: fixedUUID(),
            images: ImagesViewState(
                showImagePicker: false,
                storedPhotos: [StorableImage(uiImage: UIImage(systemName: "pencil")!)!],
                coordinateFromImagePicker: .zero
            ),
            contact: .preview,
            district: nil,
            date: fixedDate,
            description: .init(),
            location: .init(),
            mail: .init()
        )
        userDefaults = UserDefaults(suiteName: #file)
        userDefaults.removePersistentDomain(forName: #file)
    }

    func test_updateContact_ShouldUpdateState() {
        let store = TestStore(
            initialState: HomeState(),
            reducer: homeReducer,
            environment: HomeEnvironment(
                mainQueue: scheduler.eraseToAnyScheduler(),
                userDefaultsClient: .noop,
                imageConverter: .noop
            )
        )

        let newContact: ContactState = .preview

        store.assert(
            .send(.settings(.contact(.firstNameChanged(newContact.firstName)))) {
                $0.settings.contact.firstName = newContact.firstName
            }
        )
    }

    func test_updateReport_ShouldUpdateState() {
        let store = TestStore(
            initialState: HomeState(),
            reducer: homeReducer,
            environment: HomeEnvironment(
                mainQueue: scheduler.eraseToAnyScheduler(),
                userDefaultsClient: .noop,
                imageConverter: .noop
            )
        )

        let newContact: ContactState = .preview

        store.assert(
            .send(.report(.contact(.firstNameChanged(newContact.firstName)))) {
                $0.settings.contact.firstName = newContact.firstName
                $0.reportDraft.contact.firstName = newContact.firstName
            }
        )
    }

    func test_sentMailResult_shouldAppendDraftReportToReports() {
        let store = TestStore(
            initialState: HomeState(reportDraft: report),
            reducer: homeReducer,
            environment: HomeEnvironment(
                mainQueue: scheduler.eraseToAnyScheduler(),
                userDefaultsClient: .noop,
                imageConverter: .noop
            )
        )

        store.assert(
            .send(.report(.mail(.setMailResult(MFMailComposeResult(rawValue: 2))))) {
                $0.reports = [self.report]
            },
            .receive(.reportSaved) {
                $0.reportDraft = Report(images: .init(), contact: .init())
            }
        )
    }

    func test_contactStateShouldBeSaved_onContactViewDisappearAction() {
        let store = TestStore(
            initialState: HomeState(reportDraft: report),
            reducer: homeReducer,
            environment: HomeEnvironment(
                mainQueue: scheduler.eraseToAnyScheduler(),
                userDefaultsClient: .live(userDefaults: userDefaults),
                imageConverter: .noop
            )
        )

        store.assert(
            .send(.settings(.contact(.firstNameChanged("Bob")))) {
                $0.settings.contact.firstName = "Bob"
            },
            .send(.settings(.contact(.onDisappear))) {
                $0.reportDraft.contact = $0.settings.contact
                // check if contact has been saved to defaults
                XCTAssertEqual(store.environment.userDefaultsClient.contact, $0.settings.contact)
            }
        )
    }

    func test_resetReportConfirmButtonTap_shouldResetDraftReport() {
        var homeState = HomeState(reportDraft: report)
        homeState.settings.contact = .preview

        let store = TestStore(
            initialState: homeState,
            reducer: homeReducer,
            environment: HomeEnvironment(
                mainQueue: scheduler.eraseToAnyScheduler(),
                userDefaultsClient: .live(userDefaults: userDefaults),
                imageConverter: .noop
            )
        )

        store.assert(
            .send(.report(.resetConfirmButtonTapped)) {
                $0.reportDraft = Report(
                    images: .init(),
                    contact: homeState.settings.contact,
                    date: self.fixedDate
                )
            },
            .receive(.report(.dismissAlert))
        )
    }
}

private extension HomeState {
    init(reportDraft: Report) {
        self.init()
        self.reportDraft = reportDraft
    }
}
