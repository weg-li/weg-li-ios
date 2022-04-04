// Created for weg-li in 2021.

import Combine
import ComposableArchitecture
import ComposableCoreLocation
import FileClient
import ImagesFeature
import LocationFeature
import MapKit
import PlacesServiceClient
import ReportFeature
import SharedModels
import XCTest

class ReportStoreTests: XCTestCase {
  let fixedUUID = { UUID() }
  let fixedDate = { Date() }
  
  let districs = DistrictFixtures.districts
  
  var report: Report!
  
  override func setUp() {
    super.setUp()
    
    report = Report(
      uuid: fixedUUID(),
      images: ImagesViewState(
        showImagePicker: false,
        storedPhotos: [StorableImage(uiImage: UIImage(systemName: "pencil")!)!],
        coordinateFromImagePicker: .zero
      ),
      contactState: .preview,
      district: nil,
      date: fixedDate,
      description: .init()
    )
  }
  
  // MARK: - Reducer integration tests
  
  func test_updateContact_shouldUpdateState_andWriteContactToFile() {
    var didWriteContactToFile = false
    
    var fileClient = FileClient.noop
    fileClient.save = { fileName, data in
      didWriteContactToFile = fileName == "contact-settings"
      return .none
    }
    
    let store = TestStore(
      initialState: report,
      reducer: reportReducer,
      environment: ReportEnvironment(
        mainQueue: .immediate,
        backgroundQueue: .immediate,
        locationManager: LocationManager.unimplemented(),
        placeService: .noop,
        regulatoryOfficeMapper: .noop,
        fileClient: fileClient
      )
    )
    
    let firstName = "BOB"
    let lastName = "ROSS"
    let city = "Rosstown"
    
    store.send(.contact(.firstNameChanged(firstName))) {
      $0.contactState.contact.firstName = firstName
    }
    store.send(.contact(.lastNameChanged(lastName))) {
      $0.contactState.contact.name = lastName
    }
    store.send(.contact(.townChanged(city))) {
      $0.contactState.contact.address.city = city
    }
    
    XCTAssertTrue(didWriteContactToFile)
  }
  
  func test_updateCar_shouldUpdateState() {
    let store = TestStore(
      initialState: report,
      reducer: reportReducer,
      environment: ReportEnvironment(
        mainQueue: .immediate,
        backgroundQueue: .immediate,
        locationManager: LocationManager.unimplemented(),
        placeService: .noop,
        regulatoryOfficeMapper: .noop,
        fileClient: .noop
      )
    )
    
    let color = 1
    let type = 2
    store.send(.description(.setColor(color))) {
      $0.description.selectedColor = color
    }
    store.send(.description(.setBrand(type))) {
      $0.description.selectedBrand = type
    }
    
  }
  
  func test_updateCharge_shouldUpdateState() {
    let store = TestStore(
      initialState: report,
      reducer: reportReducer,
      environment: ReportEnvironment(
        mainQueue: .immediate,
        backgroundQueue: .immediate,
        locationManager: LocationManager.unimplemented(),
        placeService: .noop,
        regulatoryOfficeMapper: .noop,
        fileClient: .noop
      )
    )
    
    let duration = 42
    let type = 23
    store.send(.description(.setCharge(type))) {
      $0.description.selectedType = type
    }
    store.send(.description(.setDuraration(duration))) {
      $0.description.selectedDuration = duration
    }
  }
  
  func test_updateImages_shouldTriggerAddressResolve() {
    let locationManagerSubject = PassthroughSubject<LocationManager.Action, Never>()
    let setSubject = PassthroughSubject<Never, Never>()
  
    let image = UIImage(systemName: "pencil")!
    let coordinate: CLLocationCoordinate2D = .init(latitude: 43.32, longitude: 32.43)
    let expectedAddress = Address(
      street: Contact.preview.address.street,
      postalCode: Contact.preview.address.postalCode,
      city: Contact.preview.address.city
    )
    let expectedDistrict = District(
      name: "Hamburg",
      zip: "20095",
      email: "anzeigenbussgeldstelle@owi-verkehr.hamburg.de",
      latitude: 53.550341,
      longitude: 10.000654,
      personalEmail: false
    )
    
    let store = TestStore(
      initialState: report,
      reducer: reportReducer,
      environment: ReportEnvironment(
        mainQueue: .immediate,
        backgroundQueue: .immediate,
        mapAddressQueue: .immediate,
        locationManager: LocationManager.unimplemented(
          authorizationStatus: { .authorizedAlways },
          create: { _ in locationManagerSubject.eraseToEffect() },
          locationServicesEnabled: { true },
          set: { _, _ -> Effect<Never, Never> in setSubject.eraseToEffect() }
        ),
        placeService: PlacesServiceClient(
          placemarks: { _ in Effect(value: [expectedAddress]) }
        ),
        regulatoryOfficeMapper: .live(),
        fileClient: .noop
      )
    )
    
    store.send(.images(.addPhotos([StorableImage(uiImage: image)]))) {
      $0.images.storedPhotos = [StorableImage(uiImage: image)!]
    }
    store.send(.images(.setResolvedCoordinate(coordinate))) {
      $0.location.userLocationState.region = CoordinateRegion(center: coordinate)
    }
    store.receive(.location(.resolveLocation(coordinate))) {
      $0.location.isResolvingAddress = true
    }
    store.receive(.location(.resolveAddressFinished(.success([expectedAddress])))) {
      $0.location.isResolvingAddress = false
      $0.location.resolvedAddress = expectedAddress
    }
    store.receive(.mapAddressToDistrict(expectedAddress))
    
    store.receive(.mapDistrictFinished(.success(expectedDistrict))) {
      $0.district = expectedDistrict
    }
    
    setSubject.send(completion: .finished)
    locationManagerSubject.send(completion: .finished)
  }
  
  func test_submitButtonTap_createsMail_andPresentsMailView() {
    let image = UIImage(systemName: "pencil")!
    let store = TestStore(
      initialState: Report(
        uuid: fixedUUID(),
        images: ImagesViewState(
          showImagePicker: false,
          storedPhotos: [StorableImage(uiImage: image)!],
          coordinateFromImagePicker: .zero
        ),
        contactState: .empty,
        district: districs[0],
        date: fixedDate,
        description: .init(),
        location: LocationViewState(
          locationOption: .currentLocation,
          isMapExpanded: false,
          isResolvingAddress: false,
          resolvedAddress: .init(
            street: Report.preview.contactState.contact.address.street,
            postalCode: Report.preview.contactState.contact.address.postalCode,
            city: Report.preview.contactState.contact.address.city
          ),
          userLocationState: .init()
        )
      ),
      reducer: reportReducer,
      environment: ReportEnvironment(
        mainQueue: .immediate,
        backgroundQueue: .immediate,
        locationManager: LocationManager.unimplemented(),
        placeService: .noop,
        regulatoryOfficeMapper: .noop,
        fileClient: .noop
      )
    )
    
    store.send(ReportAction.mail(.submitButtonTapped))
    store.receive(ReportAction.mail(.presentMailContentView(true))) {
      $0.mail.isPresentingMailContent = true
    }
  }
  
  func test_locationOptionCurrentLocation_shouldTriggerResolveLocation_andSetDistrict() {
    let store = TestStore(
      initialState: report,
      reducer: reportReducer,
      environment: ReportEnvironment(
        mainQueue: .immediate,
        backgroundQueue: .immediate,
        mapAddressQueue: .immediate,
        locationManager: LocationManager.unimplemented(),
        placeService: .noop,
        regulatoryOfficeMapper: .live(districs),
        fileClient: .noop
      )
    )
    
    let expectedAddress = Address(
      street: "Teststrasse 5",
      postalCode: "12437",
      city: "Berlin"
    )
    
    store.send(.location(.resolveAddressFinished(.success([expectedAddress])))) {
      $0.location.resolvedAddress = expectedAddress
    }
    store.receive(.mapAddressToDistrict(expectedAddress))
    store.receive(.mapDistrictFinished(.success(districs[0]))) {
      $0.district = self.districs[0]
    }
    
  }
  
  func test_imagesAction_shouldNotTriggerResolveLocation_whenLocationisNotMappable() {
    let store = TestStore(
      initialState: report,
      reducer: reportReducer,
      environment: ReportEnvironment(
        mainQueue: .immediate,
        backgroundQueue: .immediate,
        mapAddressQueue: .immediate,
        locationManager: LocationManager.unimplemented(),
        placeService: .noop,
        regulatoryOfficeMapper: .live(districs),
        fileClient: .noop
      )
    )
    
    let expectedAddress = Address(
      street: "Teststrasse 5",
      postalCode: "20099",
      city: "Hamburg"
    )
    
    
    store.send(.location(.resolveAddressFinished(.success([expectedAddress])))) {
      $0.location.resolvedAddress = expectedAddress
    }
    store.receive(.mapAddressToDistrict(expectedAddress))
    store.receive(.mapDistrictFinished(.failure(.unableToMatchRegularityOffice))) {
      $0.district = nil
    }
  }
  
  func test_imagesAction_shouldFail_whenOnlyPostalCodeEnteredManually() {
    let store = TestStore(
      initialState: Report(
        uuid: fixedUUID(),
        images: ImagesViewState(
          showImagePicker: false,
          storedPhotos: [],
          coordinateFromImagePicker: .zero
        ),
        contactState: .empty,
        district: nil,
        date: fixedDate,
        description: .init(),
        location: .init(
          locationOption: .manual,
          isMapExpanded: false,
          isResolvingAddress: false,
          resolvedAddress: .init(
            street: "",
            postalCode: "1243", city: ""
          ),
          userLocationState: .init()
        )
      ),
      reducer: reportReducer,
      environment: ReportEnvironment(
        mainQueue: .immediate,
        backgroundQueue: .immediate,
        mapAddressQueue: .immediate,
        locationManager: LocationManager.unimplemented(),
        placeService: .noop,
        regulatoryOfficeMapper: .live(districs),
        fileClient: .noop
      )
    )
    
    let expectedAddress = Address(
      street: "",
      postalCode: "12437", city: ""
    )
    
    let newPostalCode = "12437"
    
    store.send(.location(.updateGeoAddressPostalCode(newPostalCode))) {
      $0.location.resolvedAddress = Address(
        street: "",
        postalCode: newPostalCode, city: ""
      )
    }
    store.receive(.mapAddressToDistrict(expectedAddress))
    store.receive(.mapDistrictFinished(.failure(.unableToMatchRegularityOffice))) {
      $0.district = nil
    }
  }
  
  func test_imagesAction_shouldSucceed_whenOnlyPostalCodeAndCityEnteredManually() {
    let store = TestStore(
      initialState: Report(
        uuid: fixedUUID(),
        images: ImagesViewState(
          showImagePicker: false,
          storedPhotos: [],
          coordinateFromImagePicker: .zero
        ),
        contactState: .empty,
        district: nil,
        date: fixedDate,
        description: .init(),
        location: .init(
          locationOption: .manual,
          isMapExpanded: false,
          isResolvingAddress: false,
          resolvedAddress: .init(
            street: "",
            postalCode: "1243", city: "Berlin"
          ),
          userLocationState: .init()
        )
      ),
      reducer: reportReducer,
      environment: ReportEnvironment(
        mainQueue: .immediate,
        backgroundQueue: .immediate,
        mapAddressQueue: .immediate,
        locationManager: LocationManager.unimplemented(),
        placeService: .noop,
        regulatoryOfficeMapper: .live(districs),
        fileClient: .noop
      )
    )
    
    let expectedAddress = Address(
      street: "",
      postalCode: "12437",
      city: "Berlin"
    )
    
    let newPostalCode = "12437"
    store.send(.location(.updateGeoAddressPostalCode(newPostalCode))) {
      $0.location.resolvedAddress = expectedAddress
    }
    store.receive(.mapAddressToDistrict(expectedAddress))
    store.receive(.mapDistrictFinished(.success(districs[0]))) {
      $0.district = self.districs[0]
    }
  }
  
  func test_removeImage_shouldSetResolvedCoordinateToNil_whenPhotosIsEmptyAfterDelete() {
    let images = [
      StorableImage(
        id: fixedUUID().uuidString,
        uiImage: UIImage(systemName: "pencil")!
      )
    ]
    let coordinate = CLLocationCoordinate2D(latitude: 23.21, longitude: 67.76)
    
    let store = TestStore(
      initialState: Report(
        uuid: fixedUUID(),
        images: ImagesViewState(
          showImagePicker: false,
          storedPhotos: images,
          coordinateFromImagePicker: coordinate
        ),
        contactState: .empty,
        district: nil,
        date: fixedDate,
        description: .init(),
        location: .init(
          locationOption: .fromPhotos,
          isMapExpanded: false,
          isResolvingAddress: false,
          resolvedAddress: .init(
            street: "TestStrasse 3",
            postalCode: "1243",
            city: "Berlin"
          ),
          userLocationState: .init()
        )
      ),
      reducer: reportReducer,
      environment: ReportEnvironment(
        mainQueue: .immediate,
        backgroundQueue: .immediate,
        locationManager: LocationManager.unimplemented(),
        placeService: .noop,
        regulatoryOfficeMapper: .live(districs),
        fileClient: .noop
      )
    )
    
    store.send(.images(.image(id: fixedUUID().uuidString, action: .removePhoto))) {
      $0.images.storedPhotos = []
      $0.images.coordinateFromImagePicker = nil
    }
  }
  
  func test_resetDataButtonTap_shouldPresentAnAlert() {
    let store = TestStore(
      initialState: Report(
        uuid: fixedUUID(),
        images: .init(),
        contactState: .empty,
        district: nil,
        date: fixedDate,
        description: .init(),
        location: .init(
          locationOption: .fromPhotos,
          isMapExpanded: false,
          isResolvingAddress: false,
          resolvedAddress: .init(
            street: "TestStrasse 3",
            postalCode: "1243", city: "Berlin"
          ),
          userLocationState: .init()
        )
      ),
      reducer: reportReducer,
      environment: ReportEnvironment(
        mainQueue: .immediate,
        backgroundQueue: .immediate,
        locationManager: LocationManager.unimplemented(),
        placeService: .noop,
        regulatoryOfficeMapper: .noop,
        fileClient: .noop
      )
    )
    
    store.send(.resetButtonTapped) {
      $0.alert = .resetReportAlert
    }
    
  }
  
  func test_setShowContact_shouldPresentAnAlert() {
    let store = TestStore(
      initialState: Report(
        uuid: fixedUUID(),
        images: .init(),
        contactState: .empty,
        district: nil,
        date: fixedDate,
        description: .init(),
        location: .init(
          locationOption: .fromPhotos,
          isMapExpanded: false,
          isResolvingAddress: false,
          resolvedAddress: .init(
            street: "TestStrasse 3",
            postalCode: "1243", city: "Berlin"
          ),
          userLocationState: .init()
        )
      ),
      reducer: reportReducer,
      environment: ReportEnvironment(
        mainQueue: .immediate,
        backgroundQueue: .immediate,
        locationManager: LocationManager.unimplemented(),
        placeService: .noop,
        regulatoryOfficeMapper: .noop,
        fileClient: .noop
      )
    )
    
    store.send(.setShowEditContact(true)) {
      $0.showEditContact = true
    }
    
  }
  
  func test_setShowDescription_shouldPresentAnAlert() {
    let store = TestStore(
      initialState: Report(
        uuid: fixedUUID(),
        images: .init(),
        contactState: .empty,
        district: nil,
        date: fixedDate,
        description: .init(),
        location: .init(
          locationOption: .fromPhotos,
          isMapExpanded: false,
          isResolvingAddress: false,
          resolvedAddress: .init(
            street: "TestStrasse 3",
            postalCode: "1243", city: "Berlin"
          ),
          userLocationState: .init()
        )
      ),
      reducer: reportReducer,
      environment: ReportEnvironment(
        mainQueue: .immediate,
        backgroundQueue: .immediate,
        locationManager: LocationManager.unimplemented(),
        placeService: .noop,
        regulatoryOfficeMapper: .noop,
        fileClient: .noop
      )
    )
    
    store.send(.setShowEditDescription(true)) {
      $0.showEditDescription = true
    }
  }
}
