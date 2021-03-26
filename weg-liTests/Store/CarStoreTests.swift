//
//  CarStoreTests.swift
//  weg-liTests
//
//  Created by Malte on 24.03.21.
//  Copyright © 2021 Martin Wilhelmi. All rights reserved.
//

@testable import weg_li
import ComposableArchitecture
import XCTest

class CarStoreTests: XCTestCase {
    
    func test_setCarColor_shouldUpdateState() {
        let store = TestStore(
            initialState: Report.Car(color: "", type: "", licensePlateNumber: ""),
            reducer: carReducer,
            environment: CarEnvironment()
        )
        
        store.assert(
            .send(.color("Rot")) { state in
                state.color = "Rot"
            }
        )
    }
    
    func test_setCarType_shouldUpdateState() {
        let store = TestStore(
            initialState: Report.Car(color: "Rot", type: "", licensePlateNumber: ""),
            reducer: carReducer,
            environment: CarEnvironment()
        )
        
        store.assert(
            .send(.type("VW")) { state in
                state.type = "VW"
            }
        )
    }
    
    func test_setCarLicensePlate_shouldUpdateState() {
        let store = TestStore(
            initialState: Report.Car(color: "Rot", type: "VW", licensePlateNumber: ""),
            reducer: carReducer,
            environment: CarEnvironment()
        )
        
        store.assert(
            .send(.licensePlateNumber("WEG-LI-101")) { state in
                state.licensePlateNumber = "WEG-LI-101"
            }
        )
    }
}
