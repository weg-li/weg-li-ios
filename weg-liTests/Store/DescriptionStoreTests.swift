// Created for weg-li in 2021.

import ComposableArchitecture
@testable import weg_li
import XCTest

class DescriptionStoreTests: XCTestCase {
    func test_setCarColor_shouldUpdateState() {
        let store = TestStore(
            initialState: DescriptionState(),
            reducer: descriptionReducer,
            environment: DescriptionEnvironment()
        )

        store.assert(
            .send(.setColor("Rot")) { state in
                state.color = "Rot"
            }
        )
    }

    func test_setCarType_shouldUpdateState() {
        let store = TestStore(
            initialState: DescriptionState(color: "Rot"),
            reducer: descriptionReducer,
            environment: DescriptionEnvironment()
        )

        store.assert(
            .send(.setType("VW")) { state in
                state.type = "VW"
            }
        )
    }

    func test_setCarLicensePlate_shouldUpdateState() {
        let store = TestStore(
            initialState: DescriptionState(color: "Rot", type: "VW", licensePlateNumber: ""),
            reducer: descriptionReducer,
            environment: DescriptionEnvironment()
        )

        store.assert(
            .send(.setLicensePlateNumber("WEG-LI-101")) { state in
                state.licensePlateNumber = "WEG-LI-101"
            }
        )
    }

    func test_selectCharge_shouldUpdateState() {
        let store = TestStore(
            initialState: DescriptionState(color: "Rot", type: "VW", licensePlateNumber: ""),
            reducer: descriptionReducer,
            environment: DescriptionEnvironment()
        )

        store.assert(
            .send(.setCharge(1)) { state in
                state.selectedType = 1
            }
        )
    }

    func test_selectDuration_shouldUpdateState() {
        let store = TestStore(
            initialState: DescriptionState(color: "Rot", type: "VW", licensePlateNumber: ""),
            reducer: descriptionReducer,
            environment: DescriptionEnvironment()
        )

        store.assert(
            .send(.setDuraration(1)) { state in
                state.selectedDuration = 1
            }
        )
    }

    func test_toggleBlockedOthers_shouldUpdateState() {
        let store = TestStore(
            initialState: DescriptionState(color: "Rot", type: "VW", licensePlateNumber: ""),
            reducer: descriptionReducer,
            environment: DescriptionEnvironment()
        )

        store.assert(
            .send(.toggleBlockedOthers) { state in
                state.blockedOthers = true
            },
            .send(.toggleBlockedOthers) { state in
                state.blockedOthers = false
            }
        )
    }
}
