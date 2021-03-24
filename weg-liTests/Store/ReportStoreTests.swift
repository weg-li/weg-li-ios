//
//  ReportStoreTests.swift
//  weg-liTests
//
//  Created by Malte on 24.03.21.
//  Copyright © 2021 Martin Wilhelmi. All rights reserved.
//

@testable import weg_li
import ComposableArchitecture
import XCTest

class ReportStoreTests: XCTestCase {
    let fixedUUID = { UUID() }
    let fixedDate = { Date() }
    
    func test_addPhoto_shouldUpdateState() {
        let store = TestStore(
            initialState: Report(
                uuid: fixedUUID(),
                storedPhotos: [],
                contact: .empty,
                district: nil,
                date: fixedDate(),
                car: .init(
                    color: "",
                    type: "",
                    licensePlateNumber: ""
                ),
                charge: .init(
                    selectedDuration: 0,
                    selectedType: 0,
                    blockedOthers: false
                )
            ),
            reducer: reportReducer,
            environment: ReportEnvironment()
        )
        
        let image = UIImage(systemName: "pencil")!
        store.assert(
            .send(.addPhoto(image)) {
                $0.storedPhotos = [
                    StorableImage(uiImage: image)!
                ]
            }
        )
    }
    
    func test_removePhoto_shouldUpdateState() {
        let image = UIImage(systemName: "pencil")!
        let store = TestStore(
            initialState: Report(
                uuid: fixedUUID(),
                storedPhotos: [StorableImage(uiImage: image)!],
                contact: .empty,
                district: nil,
                date: fixedDate(),
                car: .init(
                    color: "",
                    type: "",
                    licensePlateNumber: ""
                ),
                charge: .init(
                    selectedDuration: 0,
                    selectedType: 0,
                    blockedOthers: false
                )
            ),
            reducer: reportReducer,
            environment: ReportEnvironment()
        )
        
        store.assert(
            .send(.removePhoto(index: 0)) {
                $0.storedPhotos = []
            }
        )
    }
    
    // MARK: - Reducer integration tests
    func test_updateContact_shouldUpdateState() {
        let image = UIImage(systemName: "pencil")!
        let store = TestStore(
            initialState: Report(
                uuid: fixedUUID(),
                storedPhotos: [StorableImage(uiImage: image)!],
                contact: .empty,
                district: nil,
                date: fixedDate(),
                car: .init(
                    color: "",
                    type: "",
                    licensePlateNumber: ""
                ),
                charge: .init(
                    selectedDuration: 0,
                    selectedType: 0,
                    blockedOthers: false
                )
            ),
            reducer: reportReducer,
            environment: ReportEnvironment()
        )
        
        let firstName = "BOB"
        let lastName = "ROSS"
        let city = "Rosstown"
        store.assert(
            .send(.contact(.firstNameChanged(firstName))) {
                $0.contact.firstName = firstName
            },
            .send(.contact(.lastNameChanged(lastName))) {
                $0.contact.name = lastName
            },
            .send(.contact(.townChanged(city))) {
                $0.contact.address.city = city
            }
        )
    }
    
    func test_updateCar_shouldUpdateState() {
        let image = UIImage(systemName: "pencil")!
        let store = TestStore(
            initialState: Report(
                uuid: fixedUUID(),
                storedPhotos: [StorableImage(uiImage: image)!],
                contact: .empty,
                district: nil,
                date: fixedDate(),
                car: Report.Car(
                    color: "",
                    type: "",
                    licensePlateNumber: ""
                ),
                charge: .init(
                    selectedDuration: 0,
                    selectedType: 0,
                    blockedOthers: false
                )
            ),
            reducer: reportReducer,
            environment: ReportEnvironment()
        )
        
        let color = "Red"
        let type = "Plymouth Valiant"
        store.assert(
            .send(.car(.color(color))) {
                $0.car.color = color
            },
            .send(.car(.type(type))) {
                $0.car.type = type
            }
        )
    }
    
    func test_updateCharge_shouldUpdateState() {
        let image = UIImage(systemName: "pencil")!
        let store = TestStore(
            initialState: Report(
                uuid: fixedUUID(),
                storedPhotos: [StorableImage(uiImage: image)!],
                contact: .empty,
                district: nil,
                date: fixedDate(),
                car: Report.Car(
                    color: "",
                    type: "",
                    licensePlateNumber: ""
                ),
                charge: .init(
                    selectedDuration: 0,
                    selectedType: 0,
                    blockedOthers: false
                )
            ),
            reducer: reportReducer,
            environment: ReportEnvironment()
        )
        
        let duration = 42
        let type = 23
        store.assert(
            .send(.charge(.selectCharge(type))) {
                $0.charge.selectedType = type
            },
            .send(.charge(.selectDuraration(duration))) {
                $0.charge.selectedDuration = duration
            }
        )
    }
}
