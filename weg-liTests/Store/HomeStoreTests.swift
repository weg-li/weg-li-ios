//
//  AppStoreTests.swift
//  weg-liTests
//
//  Created by Malte on 25.03.21.
//  Copyright © 2021 Martin Wilhelmi. All rights reserved.
//

@testable import weg_li
import ComposableArchitecture
import XCTest

class HomeStoreTests: XCTestCase {
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
            }
        )
    }
}
