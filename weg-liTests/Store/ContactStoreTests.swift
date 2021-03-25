//
//  ContactStoreTests.swift
//  weg-liTests
//
//  Created by Malte on 25.03.21.
//  Copyright © 2021 Martin Wilhelmi. All rights reserved.
//

@testable import weg_li
import ComposableArchitecture
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
            },
            .receive(.isContactValid) {
                $0.isValid = true
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
            .receive(.isContactValid) {
                $0.isValid = true
            },
            // set empty name
            .send(.lastNameChanged("")) {
                $0.name = ""
            },
            .receive(.isContactValid) {
                $0.isValid = false
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
            },
            .receive(.isContactValid) {
                $0.isValid = true
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
            },
            .receive(.isContactValid) {
                $0.isValid = true
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
            },
            .receive(.isContactValid) {
                $0.isValid = true
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
            },
            .receive(.isContactValid) {
                $0.isValid = true
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
            .receive(.isContactValid) {
                $0.isValid = false
            },
            .send(.lastNameChanged("")) {
                $0.name = ""
            },
            .receive(.isContactValid) {
                $0.isValid = false
            }
        )
    }
}
