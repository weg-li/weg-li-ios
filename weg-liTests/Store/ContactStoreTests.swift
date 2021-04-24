// Created for weg-li in 2021.

import ComposableArchitecture
@testable import weg_li
import XCTest

class ContactStoreTests: XCTestCase {
    func test_changeFirstName_shouldUpdateState() {
        let store = TestStore(
            initialState: ContactState.preview,
            reducer: contactReducer,
            environment: ContactEnvironment()
        )

        let newFirstName = "Bob"
        store.assert(
            .send(.firstNameChanged(newFirstName)) {
                $0.firstName = newFirstName
            }
        )
    }

    func test_changeName_shouldUpdateState() {
        let store = TestStore(
            initialState: ContactState.preview,
            reducer: contactReducer,
            environment: ContactEnvironment()
        )

        let newName = "Ross"
        store.assert(
            .send(.lastNameChanged(newName)) {
                $0.name = newName
            },
            // set empty name
            .send(.lastNameChanged("")) {
                $0.name = ""
            }
        )
    }

    func test_changePhone_shouldUpdateState() {
        let store = TestStore(
            initialState: ContactState.preview,
            reducer: contactReducer,
            environment: ContactEnvironment()
        )

        let newPhone = "0301234"
        store.assert(
            .send(.phoneChanged(newPhone)) {
                $0.phone = newPhone
            }
        )
    }

    func test_changeStreet_shouldUpdateState() {
        let store = TestStore(
            initialState: ContactState.preview,
            reducer: contactReducer,
            environment: ContactEnvironment()
        )

        let newStreet = "Bob's street"
        store.assert(
            .send(.streetChanged(newStreet)) {
                $0.address.street = newStreet
            }
        )
    }

    func test_changeCity_shouldUpdateState() {
        let store = TestStore(
            initialState: ContactState.preview,
            reducer: contactReducer,
            environment: ContactEnvironment()
        )

        let newCity = "Bob's city"
        store.assert(
            .send(.townChanged(newCity)) {
                $0.address.city = newCity
            }
        )
    }

    func test_changePostalCode_shouldUpdateState() {
        let store = TestStore(
            initialState: ContactState.preview,
            reducer: contactReducer,
            environment: ContactEnvironment()
        )

        let newPostalCode = "55500"
        store.assert(
            .send(.zipCodeChanged(newPostalCode)) {
                $0.address.postalCode = newPostalCode
            }
        )
    }
    
    func test_changeDateOfBirth_shouldUpdateState() {
        let store = TestStore(
            initialState: ContactState.preview,
            reducer: contactReducer,
            environment: ContactEnvironment()
        )

        let newValue = "01.01.2992"
        store.assert(
            .send(.dateOfBirthChanged(newValue)) {
                $0.dateOfBirth = newValue
            }
        )
    }
    
    func test_changeAddressAddition_shouldUpdateState() {
        let store = TestStore(
            initialState: ContactState.preview,
            reducer: contactReducer,
            environment: ContactEnvironment()
        )

        let newValue = "Hinterhaus"
        store.assert(
            .send(.addressAdditionChanged(newValue)) {
                $0.address.addition = newValue
            }
        )
    }
    
    func test_setEmptyValues_shouldInvalidContact() {
        let store = TestStore(
            initialState: ContactState.preview,
            reducer: contactReducer,
            environment: ContactEnvironment()
        )

        store.assert(
            .send(.zipCodeChanged("")) {
                $0.address.postalCode = ""
            },
            .send(.lastNameChanged("")) {
                $0.name = ""

                XCTAssertFalse($0.isValid)
            }
        )
    }

    func test_resetData_ButtonTap_PresentAnAlert() {
        let store = TestStore(
            initialState: ContactState.preview,
            reducer: contactReducer,
            environment: ContactEnvironment()
        )

        store.assert(
            .send(.resetContactDataButtonTapped) {
                $0.alert = .resetContactDataAlert
            }
        )
    }

    func test_resetData_ConfirmButtonTap_shouldResetTheState_andDismissAlert() {
        let store = TestStore(
            initialState: ContactState.preview,
            reducer: contactReducer,
            environment: ContactEnvironment()
        )

        store.assert(
            .send(.resetContactConfirmButtonTapped) {
                $0 = .empty
            },
            .receive(.dismissAlert)
        )
    }
}
