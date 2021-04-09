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
                    resolvedLocation: .zero
                ),
                contact: .preview,
                district: nil,
                date: fixedDate,
                description: .init()
            ),
            reducer: reportReducer,
            environment: ReportEnvironment(
                mainQueue: DispatchQueue.immediate.eraseToAnyScheduler(),
                locationManager: LocationManager.unimplemented(),
                placeService: PlacesServiceMock(),
                regulatoryOfficeMapper: .noop
            )
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
                images: ImagesViewState(
                    showImagePicker: false,
                    storedPhotos: [StorableImage(uiImage: image)!],
                    resolvedLocation: .zero
                ),
                contact: .empty,
                district: nil,
                date: fixedDate,
                description: .init()
            ),
            reducer: reportReducer,
            environment: ReportEnvironment(
                mainQueue: DispatchQueue.immediate.eraseToAnyScheduler(),
                locationManager: LocationManager.unimplemented(),
                placeService: PlacesServiceMock(),
                regulatoryOfficeMapper: .noop
            )
        )

        let color = "Red"
        let type = "Plymouth Valiant"
        store.assert(
            .send(.description(.setColor(color))) {
                $0.description.color = color
            },
            .send(.description(.setType(type))) {
                $0.description.type = type
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
                    resolvedLocation: .zero
                ),
                contact: .empty,
                district: nil,
                date: fixedDate,
                description: .init()
            ),
            reducer: reportReducer,
            environment: ReportEnvironment(
                mainQueue: DispatchQueue.immediate.eraseToAnyScheduler(),
                locationManager: LocationManager.unimplemented(),
                placeService: PlacesServiceMock(),
                regulatoryOfficeMapper: .noop
            )
        )

        let duration = 42
        let type = 23
        store.assert(
            .send(.description(.setCharge(type))) {
                $0.description.selectedType = type
            },
            .send(.description(.setDuraration(duration))) {
                $0.description.selectedDuration = duration
            }
        )
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
                    resolvedLocation: .zero
                ),
                contact: .empty,
                district: nil,
                date: fixedDate,
                description: .init()
            ),
            reducer: reportReducer,
            environment: ReportEnvironment(
                mainQueue: DispatchQueue.immediate.eraseToAnyScheduler(),
                locationManager: LocationManager.unimplemented(),
                placeService: PlacesServiceMock(getPlacesSubject: placesSubject),
                regulatoryOfficeMapper: .noop
            )
        )

        let coordinate: CLLocationCoordinate2D = .init(latitude: 43.32, longitude: 32.43)
        let expectedAddress = GeoAddress(
            street: ContactState.preview.address.street,
            city: ContactState.preview.address.city,
            postalCode: ContactState.preview.address.postalCode
        )

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
            .receive(.mapGeoAddressToDistrict(expectedAddress)),
            .do { placesSubject.send(completion: .finished) }
        )
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
                    resolvedLocation: .zero
                ),
                contact: .empty,
                district: District(name: "Berlin", zipCode: "12437", mail: "amt@berlin.da"),
                date: fixedDate,
                description: .init(),
                location: LocationViewState(
                    locationOption: .currentLocation,
                    isMapExpanded: false,
                    isResolvingAddress: false,
                    resolvedAddress: .init(
                        street: Report.preview.contact.address.street,
                        city: Report.preview.contact.address.city,
                        postalCode: Report.preview.contact.address.postalCode
                    ),
                    storedPhotos: [StorableImage(uiImage: image)!],
                    userLocationState: .init()
                )
            ),
            reducer: reportReducer,
            environment: ReportEnvironment(
                mainQueue: DispatchQueue.immediate.eraseToAnyScheduler(),
                locationManager: LocationManager.unimplemented(),
                placeService: PlacesServiceMock(getPlacesSubject: placesSubject),
                regulatoryOfficeMapper: .noop
            )
        )

        store.assert(
            .send(ReportAction.mail(.submitButtonTapped)),
            .receive(ReportAction.mail(.presentMailContentView(true))) {
                $0.mail.isPresentingMailContent = false
            }
        )
    }
}
