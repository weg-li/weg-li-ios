// Created for weg-li in 2021.

import Combine
import ComposableArchitecture
import ComposableCoreLocation
import MapKit
@testable import weg_li
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
                    resolvedLocation: .zero),
                contact: .preview,
                district: nil,
                date: fixedDate,
                car: .init(
                    color: "",
                    type: "",
                    licensePlateNumber: ""),
                charge: .init(
                    selectedDuration: 0,
                    selectedType: 0,
                    blockedOthers: false)),
            reducer: reportReducer,
            environment: ReportEnvironment(
                locationManager: LocationManager.unimplemented(),
                placeService: PlacesServiceMock(),
                regulatoryOfficeMapper: RegulatoryOfficeMapper(districtsRepo: DistrictRepository())))

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
            .receive(.contact(.isContactValid)))
    }

    func test_updateCar_shouldUpdateState() {
        let image = UIImage(systemName: "pencil")!
        let store = TestStore(
            initialState: Report(
                uuid: fixedUUID(),
                images: ImagesViewState(
                    showImagePicker: false,
                    storedPhotos: [StorableImage(uiImage: image)!],
                    resolvedLocation: .zero),
                contact: .empty,
                district: nil,
                date: fixedDate,
                car: Report.Car(
                    color: "",
                    type: "",
                    licensePlateNumber: ""),
                charge: .init(
                    selectedDuration: 0,
                    selectedType: 0,
                    blockedOthers: false)),
            reducer: reportReducer,
            environment: ReportEnvironment(
                locationManager: LocationManager.unimplemented(),
                placeService: PlacesServiceMock(),
                regulatoryOfficeMapper: RegulatoryOfficeMapper(districtsRepo: DistrictRepositoryMock())))

        let color = "Red"
        let type = "Plymouth Valiant"
        store.assert(
            .send(.car(.color(color))) {
                $0.car.color = color
            },
            .send(.car(.type(type))) {
                $0.car.type = type
            })
    }

    func test_updateCharge_shouldUpdateState() {
        let image = UIImage(systemName: "pencil")!
        let store = TestStore(
            initialState: Report(
                uuid: fixedUUID(),
                images: ImagesViewState(
                    showImagePicker: false,
                    storedPhotos: [StorableImage(uiImage: image)!],
                    resolvedLocation: .zero),
                contact: .empty,
                district: nil,
                date: fixedDate,
                car: Report.Car(
                    color: "",
                    type: "",
                    licensePlateNumber: ""),
                charge: .init(
                    selectedDuration: 0,
                    selectedType: 0,
                    blockedOthers: false)),
            reducer: reportReducer,
            environment: ReportEnvironment(
                locationManager: LocationManager.unimplemented(),
                placeService: PlacesServiceMock(),
                regulatoryOfficeMapper: RegulatoryOfficeMapper(districtsRepo: DistrictRepositoryMock())))

        let duration = 42
        let type = 23
        store.assert(
            .send(.charge(.selectCharge(type))) {
                $0.charge.selectedType = type
            },
            .send(.charge(.selectDuraration(duration))) {
                $0.charge.selectedDuration = duration
            })
    }

    func test_updateImages_shouldTriggerAddressResolve() {
        let image = UIImage(systemName: "pencil")!
        let placesSubject = PassthroughSubject<[GeoAddress], PlacesServiceImplementation.Error>()

        let store = TestStore(
            initialState: Report(
                uuid: fixedUUID(),
                images: ImagesViewState(
                    showImagePicker: false,
                    storedPhotos: [StorableImage(uiImage: image)!],
                    resolvedLocation: .zero),
                contact: .empty,
                district: nil,
                date: fixedDate,
                car: Report.Car(
                    color: "",
                    type: "",
                    licensePlateNumber: ""),
                charge: .init(
                    selectedDuration: 0,
                    selectedType: 0,
                    blockedOthers: false)),
            reducer: reportReducer,
            environment: ReportEnvironment(
                locationManager: LocationManager.unimplemented(),
                placeService: PlacesServiceMock(getPlacesSubject: placesSubject),
                regulatoryOfficeMapper: RegulatoryOfficeMapper(districtsRepo: DistrictRepositoryMock())))

        let coordinate: CLLocationCoordinate2D = .init(latitude: 43.32, longitude: 32.43)
        let expectedAddress = GeoAddress(
            street: ContactState.preview.address.street,
            city: ContactState.preview.address.city,
            postalCode: ContactState.preview.address.postalCode)

        store.assert(
            .send(.images(.addPhotos([StorableImage(uiImage: image)]))) {
                $0.images.storedPhotos = [StorableImage(uiImage: image)!]
            },
            .send(.images(.setResolvedCoordinate(coordinate))) {
                $0.location.userLocationState.region = CoordinateRegion(center: coordinate)
            },
            .receive(.location(.resolveLocation(coordinate))) {
                $0.location.isResolvingAddress = true
            },
            .do { placesSubject.send([expectedAddress]) },
            .receive(.location(.resolveAddressFinished(.success([expectedAddress])))) {
                $0.location.isResolvingAddress = false
                $0.location.resolvedAddress = expectedAddress
            },
            .do { placesSubject.send(completion: .finished) })
    }

    func test_submitButtonTap_createsMail_andPresentsMailView() {
        let image = UIImage(systemName: "pencil")!
        let placesSubject = PassthroughSubject<[GeoAddress], PlacesServiceImplementation.Error>()

        let store = TestStore(
            initialState: Report(
                uuid: fixedUUID(),
                images: ImagesViewState(
                    showImagePicker: false,
                    storedPhotos: [StorableImage(uiImage: image)!],
                    resolvedLocation: .zero),
                contact: .empty,
                district: nil,
                date: fixedDate,
                car: Report.Car(
                    color: "",
                    type: "",
                    licensePlateNumber: ""),
                charge: .init(
                    selectedDuration: 0,
                    selectedType: 0,
                    blockedOthers: false),
                location: LocationViewState(
                    locationOption: .currentLocation,
                    isMapExpanded: false,
                    isResolvingAddress: false,
                    resolvedAddress: .init(
                        street: Report.preview.contact.address.street,
                        city: Report.preview.contact.address.city,
                        postalCode: Report.preview.contact.address.postalCode),
                    storedPhotos: [StorableImage(uiImage: image)!],
                    userLocationState: .init())),
            reducer: reportReducer,
            environment: ReportEnvironment(
                locationManager: LocationManager.unimplemented(),
                placeService: PlacesServiceMock(getPlacesSubject: placesSubject),
                regulatoryOfficeMapper: RegulatoryOfficeMapper(districtsRepo: DistrictRepositoryMock())))

        store.assert(
            .send(ReportAction.mail(.submitButtonTapped)),
            .receive(ReportAction.mail(.presentMailContentView(true))) {
                $0.mail.isPresentingMailContent = false
            })
    }
}
