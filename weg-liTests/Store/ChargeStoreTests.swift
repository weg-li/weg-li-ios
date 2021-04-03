// Created for weg-li in 2021.

import ComposableArchitecture
@testable import weg_li
import XCTest

class ChargeStoreTests: XCTestCase {
    func test_selectCharge_shouldUpdateState() {
        let store = TestStore(
            initialState: Report.Charge(
                selectedDuration: 0,
                selectedType: 0,
                blockedOthers: false),
            reducer: chargeReducer,
            environment: ChargeEnvironment())

        store.assert(
            .send(.selectCharge(1)) { state in
                state.selectedType = 1
            }
        )
    }

    func test_selectDuration_shouldUpdateState() {
        let store = TestStore(
            initialState: Report.Charge(
                selectedDuration: 0,
                selectedType: 0,
                blockedOthers: false),
            reducer: chargeReducer,
            environment: ChargeEnvironment())

        store.assert(
            .send(.selectDuraration(1)) { state in
                state.selectedDuration = 1
            }
        )
    }

    func test_toggleBlockedOthers_shouldUpdateState() {
        let store = TestStore(
            initialState: Report.Charge(
                selectedDuration: 0,
                selectedType: 0,
                blockedOthers: false),
            reducer: chargeReducer,
            environment: ChargeEnvironment())

        store.assert(
            .send(.toggleBlockedOthers) { state in
                state.blockedOthers = true
            },
            .send(.toggleBlockedOthers) { state in
                state.blockedOthers = false
            })
    }
}
