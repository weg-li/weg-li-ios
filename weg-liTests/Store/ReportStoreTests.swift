//
//  ReportStoreTests.swift
//  weg-liTests
//
//  Created by Malte on 24.03.21.
//  Copyright © 2021 Martin Wilhelmi. All rights reserved.
//

@testable import weg_li
import ComposableArchitecture
import ComposableCoreLocation
import XCTest

class ReportStoreTests: XCTestCase {
    let fixedUUID = { UUID() }
    let fixedDate = { Date() }
    
    // MARK: - Reducer integration tests
    func test_updateContact_shouldUpdateState() {
        let image = UIImage(systemName: "pencil")!
        let store = TestStore(
            initialState: Report(
                uuid: fixedUUID(),
                images: ImagesViewState(
                    showImagePicker: false,
                    storedPhotos: [StorableImage(uiImage: image)!],
                    resolvedLocation: nil
                ),
                contact: .preview,
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
            environment: ReportEnvironment(
                locationManager: LocationManager.unimplemented(),
                placeService: PlacesServiceMock()
            )
        )
        
        let firstName = "BOB"
        let lastName = "ROSS"
        let city = "Rosstown"
        store.assert(
            .send(.contact(.firstNameChanged(firstName))) {
                $0.contact.firstName = firstName
            },
            .receive(.contact(.isContactValid)) {
                $0.contact.isValid = true
            },
            .send(.contact(.lastNameChanged(lastName))) {
                $0.contact.name = lastName
            },
            .receive(.contact(.isContactValid)),
            .send(.contact(.townChanged(city))) {
                $0.contact.address.city = city
            },
            .receive(.contact(.isContactValid))
        )
    }
    
    func test_updateCar_shouldUpdateState() {
        let image = UIImage(systemName: "pencil")!
        let store = TestStore(
            initialState: Report(
                uuid: fixedUUID(),
                images: ImagesViewState(
                    showImagePicker: false,
                    storedPhotos: [StorableImage(uiImage: image)!],
                    resolvedLocation: nil
                ),
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
            environment: ReportEnvironment(
                locationManager: LocationManager.unimplemented(),
                placeService: PlacesServiceMock()
            )
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
                images: ImagesViewState(
                    showImagePicker: false,
                    storedPhotos: [StorableImage(uiImage: image)!],
                    resolvedLocation: nil
                ),
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
            environment: ReportEnvironment(
                locationManager: LocationManager.unimplemented(),
                placeService: PlacesServiceMock()
            )
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
