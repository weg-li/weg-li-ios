// Created for weg-li in 2021.

import ApiClient
import Combine
import ComposableArchitecture
import ComposableCoreLocation
import DescriptionFeature
import FileClient
import ImagesFeature
import ImagesUploadClient
import LocationFeature
import MapKit
import PlacesServiceClient
import RegulatoryOfficeMapper
import ReportFeature
import SharedModels
import XCTest

@MainActor
final class ReportStoreTests: XCTestCase {
  let fixedUUID = { UUID(uuidString: "de71ce00-dead-beef-dead-beefdeadbeef")! }
  let fixedDate = { Date() }
  
  let districs = DistrictFixtures.districts
  
  var report: ReportState!
  
  let mainQueue = DispatchQueue.test
  
  override func setUp() {
    super.setUp()
    
    report = ReportState(
      uuid: fixedUUID,
      images: ImagesViewState(
        showImagePicker: false,
        storedPhotos: [PickerImageResult(uiImage: UIImage(systemName: "pencil")!)!],
        coordinateFromImagePicker: .zero
      ),
      contactState: .preview,
      district: nil,
      date: fixedDate,
      description: .init()
    )
  }
  
  func test_updateDate_shouldUpdateState() {
    let store = TestStore(
      initialState: report,
      reducer: reportReducer,
      environment: ReportEnvironment(
        mainQueue: .immediate,
        backgroundQueue: .immediate,
        locationManager: LocationManager.unimplemented(),
        placeService: .noop,
        regulatoryOfficeMapper: .noop,
        fileClient: .noop,
        wegliService: .noop,
        date: Date.init
      )
    )
    
    let newDate = Date(timeIntervalSinceReferenceDate: 0)
    
    store.send(.setDate(newDate)) {
      $0.date = newDate
    }
  }
  
  // MARK: - Reducer integration tests
  
  func test_updateContact_shouldUpdateState_andWriteContactToFile() async {
    let didWriteContactToFile = ActorIsolated(false)
    
    var fileClient = FileClient.noop
    fileClient.save = { @Sendable fileName, _ in
      await didWriteContactToFile.setValue(fileName == "contact-settings")
      return ()
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
        fileClient: fileClient,
        wegliService: .noop,
        date: Date.init
      )
    )
    
    let firstName = "BOB"
    let lastName = "ROSS"
    let city = "Rosstown"
    
    await store.send(.contact(.contact(.set(\.$firstName, firstName)))) {
      $0.contactState.contact.firstName = firstName
    }
    try? await Task.sleep(nanoseconds: NSEC_PER_SEC / 3)
    await store.send(.contact(.contact(.set(\.$name, lastName)))) {
      $0.contactState.contact.name = lastName
    }
    try? await Task.sleep(nanoseconds: NSEC_PER_SEC / 3)
    await store.send(.contact(.contact(.set(\.address.$city, city)))) {
      $0.contactState.contact.address.city = city
    }
    await didWriteContactToFile.withValue({ value in
      XCTAssertTrue(value)
    })
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
        fileClient: .noop,
        wegliService: .noop,
        date: Date.init
      )
    )
    
    let color = 1
    let brand = CarBrand("Opel")
    store.send(.description(.setColor(color))) {
      $0.description.selectedColor = color
    }
    store.send(.description(.setBrand(brand))) {
      $0.description.selectedBrand = brand
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
        fileClient: .noop,
        wegliService: .noop,
        date: Date.init
      )
    )
    
    let duration = 42
    let testCharge = Charge(id: "1", text: "2", isFavorite: false, isSelected: true)
    store.send(.description(.setCharge(testCharge))) {
      $0.description.selectedCharge = testCharge
    }
    store.send(.description(.setDuration(duration))) {
      $0.description.selectedDuration = duration
    }
  }
  
  func test_updateImages_shouldTriggerAddressResolve() async {
    let locationManagerSubject = PassthroughSubject<LocationManager.Action, Never>()
    let setSubject = PassthroughSubject<Never, Never>()
  
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
        mainQueue: mainQueue.eraseToAnyScheduler(),
        backgroundQueue: .immediate,
        mapAddressQueue: .immediate,
        locationManager: LocationManager.unimplemented(
          authorizationStatus: { .authorizedAlways },
          create: { _ in locationManagerSubject.eraseToEffect() },
          locationServicesEnabled: { true },
          set: { _, _ -> Effect<Never, Never> in setSubject.eraseToEffect() }
        ),
        placeService: PlacesServiceClient(
          placemarks: { _ in [expectedAddress] }
        ),
        regulatoryOfficeMapper: .live(),
        fileClient: .noop,
        wegliService: .noop,
        date: Date.init
      )
    )
    
    let creationDate: Date = .init(timeIntervalSince1970: 0)
    
    let storedImage = PickerImageResult(
      id: "1",
      imageUrl: nil,
      coordinate: .init(coordinate),
      creationDate: creationDate
    )

    await store.send(.images(.setPhotos([storedImage]))) {
      $0.images.isRecognizingTexts = true
      var images = self.report.images.storedPhotos
      images.append(storedImage)
      $0.images.storedPhotos = images
    }
    await store.receive(.images(.setImageCoordinate(coordinate))) {
      $0.images.pickerResultCoordinate = coordinate
      
      $0.location.region = CoordinateRegion(center: coordinate)
      $0.location.pinCoordinate = coordinate
      $0.images.pickerResultCoordinate = coordinate
    }
    await store.receive(.images(.setImageCreationDate(creationDate))) {
      $0.images.pickerResultDate = creationDate
      $0.date = creationDate
    }
    
    await store.receive(.location(.resolveLocation(coordinate))) {
      $0.location.isResolvingAddress = true
    }
    await mainQueue.advance(by: 1)
    
    await store.receive(.images(.textRecognitionCompleted(.failure(VisionError.missingCGImage)))) {
      $0.images.isRecognizingTexts = false
    }
    
    await store.receive(.location(.resolveAddressFinished(.success([expectedAddress])))) {
      $0.location.isResolvingAddress = false
      $0.location.resolvedAddress = expectedAddress
    }
    
    await store.receive(.mapAddressToDistrict(expectedAddress))
    await store.receive(.mapDistrictFinished(.success(expectedDistrict))) {
      $0.district = expectedDistrict
    }
    
    setSubject.send(completion: .finished)
    locationManagerSubject.send(completion: .finished)
  }
  
  func test_submitButtonTap_createsMail_andPresentsMailView() {
    let image = UIImage(systemName: "pencil")!
    let store = TestStore(
      initialState: ReportState(
        uuid: fixedUUID,
        images: ImagesViewState(
          showImagePicker: false,
          storedPhotos: [PickerImageResult(uiImage: image)!],
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
            street: ReportState.preview.contactState.contact.address.street,
            postalCode: ReportState.preview.contactState.contact.address.postalCode,
            city: ReportState.preview.contactState.contact.address.city
          )
        )
      ),
      reducer: reportReducer,
      environment: ReportEnvironment(
        mainQueue: .immediate,
        backgroundQueue: .immediate,
        locationManager: LocationManager.unimplemented(),
        placeService: .noop,
        regulatoryOfficeMapper: .noop,
        fileClient: .noop,
        wegliService: .noop,
        date: Date.init
      )
    )
    store.environment.canSendMail = { true }
    
    store.send(ReportAction.mail(.submitButtonTapped)) {
      $0.mail.mail.address = "Anzeige@bowi.berlin.de"
      $0.mail.mail.body = $0.createMailBody()
    }
    store.receive(ReportAction.mail(.presentMailContentView(true))) {
      $0.mail.isPresentingMailContent = true
    }
  }
  
  func test_submitButtonTap_createsMail_butShowsError() {
    let image = UIImage(systemName: "pencil")!
    let store = TestStore(
      initialState: ReportState(
        uuid: fixedUUID,
        images: ImagesViewState(
          showImagePicker: false,
          storedPhotos: [PickerImageResult(uiImage: image)!],
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
            street: ReportState.preview.contactState.contact.address.street,
            postalCode: ReportState.preview.contactState.contact.address.postalCode,
            city: ReportState.preview.contactState.contact.address.city
          )
        )
      ),
      reducer: reportReducer,
      environment: ReportEnvironment(
        mainQueue: .immediate,
        backgroundQueue: .immediate,
        locationManager: LocationManager.unimplemented(),
        placeService: .noop,
        regulatoryOfficeMapper: .noop,
        fileClient: .noop,
        wegliService: .noop,
        date: Date.init
      )
    )
    store.environment.canSendMail = { false }
    
    store.send(ReportAction.mail(.submitButtonTapped)) {
      $0.alert = .noMailAccount
    }
  }
  
  func test_locationOptionCurrentLocation_shouldTriggerResolveLocation_andSetDistrict() async {
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
        fileClient: .noop,
        wegliService: .noop,
        date: Date.init
      )
    )
    
    let expectedAddress = Address(
      street: "Teststrasse 5",
      postalCode: "12437",
      city: "Berlin"
    )
    
    await store.send(.location(.resolveAddressFinished(.success([expectedAddress])))) {
      $0.location.resolvedAddress = expectedAddress
    }
    await store.receive(.mapAddressToDistrict(expectedAddress))
    await store.receive(.mapDistrictFinished(.success(districs[0]))) {
      $0.district = self.districs[0]
    }
  }
  
  func test_locationOptionCurrentLocation_shouldPresentOfflineError_whenClientHasNoInternetConnection() {
    let coordinate = CLLocationCoordinate2D(latitude: 31.31, longitude: 12.12)
    
    var state = report
    state?.isNetworkAvailable = false
    state?.location.pinCoordinate = coordinate
    
    let store = TestStore(
      initialState: state!,
      reducer: reportReducer,
      environment: ReportEnvironment(
        mainQueue: .immediate,
        backgroundQueue: .immediate,
        mapAddressQueue: .immediate,
        locationManager: LocationManager.unimplemented(),
        placeService: .noop,
        regulatoryOfficeMapper: .live(districs),
        fileClient: .noop,
        wegliService: .noop,
        date: Date.init
      )
    )
        
    store.send(.images(.setImageCoordinate(coordinate))) {
      $0.images.pickerResultCoordinate = coordinate
      $0.location.pinCoordinate = coordinate
      $0.location.region = .init(center: .init(coordinate), span: .init(latitudeDelta: 0.005, longitudeDelta: 0.005))
      
      $0.alert = .init(
        title: .init("Keine Internetverbindung"),
        message: .init("Verbinde dich mit dem Internet um eine Adresse für die Fotos zu ermitteln"),
        buttons: [
          .cancel(.init("Abbrechen")),
          .default(.init("Wiederholen"), action: .send(.location(.resolveLocation((state?.location.pinCoordinate!)!))))
        ]
      )
    }
  }
  
  func test_imagesAction_shouldNotTriggerResolveLocation_whenLocationisNotMappable() async {
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
        fileClient: .noop,
        wegliService: .noop,
        date: Date.init
      )
    )
    
    let expectedAddress = Address(
      street: "Teststrasse 5",
      postalCode: "20099",
      city: "Hamburg"
    )
    
    await store.send(.location(.resolveAddressFinished(.success([expectedAddress])))) {
      $0.location.resolvedAddress = expectedAddress
    }
    await store.receive(.mapAddressToDistrict(expectedAddress))
    await store.receive(.mapDistrictFinished(TaskResult.failure(RegularityOfficeMapError.unableToMatchRegularityOffice)))
  }
  
  func test_imagesAction_shouldFail_whenOnlyPostalCodeEnteredManually() async {
    let store = TestStore(
      initialState: ReportState(
        uuid: fixedUUID,
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
          )
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
        fileClient: .noop,
        wegliService: .noop,
        date: Date.init
      )
    )
    
    let expectedAddress = Address(
      street: "",
      postalCode: "12437", city: ""
    )
    
    let newPostalCode = "12437"
    
    await store.send(.location(.updateGeoAddressPostalCode(newPostalCode))) {
      $0.location.resolvedAddress = Address(
        street: "",
        postalCode: newPostalCode, city: ""
      )
    }
    await store.receive(.mapAddressToDistrict(expectedAddress))
    await store.receive(.mapDistrictFinished(TaskResult.failure(RegularityOfficeMapError.unableToMatchRegularityOffice)))
  }
  
  func test_imagesAction_shouldSucceed_whenOnlyPostalCodeAndCityEnteredManually() async {
    let store = TestStore(
      initialState: ReportState(
        uuid: fixedUUID,
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
          )
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
        fileClient: .noop,
        wegliService: .noop,
        date: Date.init
      )
    )
    
    let expectedAddress = Address(
      street: "",
      postalCode: "12437",
      city: "Berlin"
    )
    
    let newPostalCode = "12437"
    await store.send(.location(.updateGeoAddressPostalCode(newPostalCode))) {
      $0.location.resolvedAddress = expectedAddress
    }
    await store.receive(.mapAddressToDistrict(expectedAddress))
    await store.receive(.mapDistrictFinished(.success(districs[0]))) {
      $0.district = self.districs[0]
    }
  }
  
  func test_removeImage_shouldSetResolvedCoordinateToNil_whenPhotosIsEmptyAfterDelete() {
    let images = [
      PickerImageResult(
        id: "123",
        uiImage: UIImage(systemName: "pencil")!
      )
    ]
    let coordinate = CLLocationCoordinate2D(latitude: 23.21, longitude: 67.76)
    let testDate = { Date(timeIntervalSinceReferenceDate: 0) }
    
    let store = TestStore(
      initialState: ReportState(
        uuid: fixedUUID,
        images: ImagesViewState(
          showImagePicker: false,
          storedPhotos: images,
          coordinateFromImagePicker: coordinate
        ),
        contactState: .empty,
        district: nil,
        date: testDate,
        description: .init(),
        location: .init(
          locationOption: .fromPhotos,
          isMapExpanded: false,
          isResolvingAddress: false,
          resolvedAddress: .init(
            street: "TestStrasse 3",
            postalCode: "1243",
            city: "Berlin"
          )
        )
      ),
      reducer: reportReducer,
      environment: ReportEnvironment(
        mainQueue: .immediate,
        backgroundQueue: .immediate,
        locationManager: LocationManager.unimplemented(),
        placeService: .noop,
        regulatoryOfficeMapper: .live(districs),
        fileClient: .noop,
        wegliService: .noop,
        date: testDate
      )
    )
    
    store.send(.images(.image(id: "123", action: .removePhoto))) {
      $0.date = testDate()
      $0.images.storedPhotos = []
      $0.location.resolvedAddress = .init()
      $0.images.pickerResultCoordinate = nil
    }
  }
  
  func test_resetDataButtonTap_shouldPresentAnAlert() {
    let store = TestStore(
      initialState: ReportState(
        uuid: fixedUUID,
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
          )
        )
      ),
      reducer: reportReducer,
      environment: ReportEnvironment(
        mainQueue: .immediate,
        backgroundQueue: .immediate,
        locationManager: LocationManager.unimplemented(),
        placeService: .noop,
        regulatoryOfficeMapper: .noop,
        fileClient: .noop,
        wegliService: .noop,
        date: Date.init
      )
    )
    
    store.send(.resetButtonTapped) {
      $0.alert = .resetReportAlert
    }
  }
  
  func test_setShowContact_shouldPresentAnAlert() {
    let store = TestStore(
      initialState: ReportState(
        uuid: fixedUUID,
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
          )
        )
      ),
      reducer: reportReducer,
      environment: ReportEnvironment(
        mainQueue: .immediate,
        backgroundQueue: .immediate,
        locationManager: LocationManager.unimplemented(),
        placeService: .noop,
        regulatoryOfficeMapper: .noop,
        fileClient: .noop,
        wegliService: .noop,
        date: Date.init
      )
    )
    
    store.send(.setShowEditContact(true)) {
      $0.showEditContact = true
    }
  }
  
  func test_setShowDescription_shouldPresentAnAlert() {
    let store = TestStore(
      initialState: ReportState(
        uuid: fixedUUID,
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
          )
        )
      ),
      reducer: reportReducer,
      environment: ReportEnvironment(
        mainQueue: .immediate,
        backgroundQueue: .immediate,
        locationManager: LocationManager.unimplemented(),
        placeService: .noop,
        regulatoryOfficeMapper: .noop,
        fileClient: .noop,
        wegliService: .noop,
        date: Date.init
      )
    )
    
    store.send(.setShowEditDescription(true)) {
      $0.showEditDescription = true
    }
  }
  
  func test_selectedLicensePlate_shouldSetDescriptionState() {
    let store = TestStore(
      initialState: ReportState(
        uuid: fixedUUID,
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
          )
        )
      ),
      reducer: reportReducer,
      environment: ReportEnvironment(
        mainQueue: .immediate,
        backgroundQueue: .immediate,
        locationManager: LocationManager.unimplemented(),
        placeService: .noop,
        regulatoryOfficeMapper: .noop,
        fileClient: .noop,
        wegliService: .noop,
        date: Date.init
      )
    )
    
    let item = TextItem(id: "123", text: "B-MB 3000")
    store.send(.images(.selectedTextItem(item))) {
      $0.description.licensePlateNumber = item.text
    }
  }
  
  func test_action_uploadImages() async {
    let responses: [ImageUploadResponse] = [
      .init(
        id: 1,
        key: "key",
        filename: "filename",
        contentType: "type",
        byteSize: 123,
        checksum: "wer",
        createdAt: Date(timeIntervalSince1970: 0),
        signedId: "111",
        directUpload: .init(url: "123", headers: [:])
      ),
      .init(
        id: 2,
        key: "key",
        filename: "filename",
        contentType: "type",
        byteSize: 123,
        checksum: "wer",
        createdAt: Date(timeIntervalSince1970: 0),
        signedId: "222",
        directUpload: .init(url: "321", headers: [:])
      )
    ]
    let imagesUploadClient = ImagesUploadClient(uploadImages: { _ in responses })
    
    var wegliService = WegliAPIService.noop
    wegliService.postNotice = { _ in .mock }
    
    let didRemoveImageItems = ActorIsolated(false)
    var fileClient = FileClient.noop
    fileClient.removeItem = { @Sendable _ in
      await didRemoveImageItems.setValue(true)
      return ()
    }
    
    let store = TestStore(
      initialState: ReportState(
        uuid: fixedUUID,
        images: .init(
          alert: nil,
          showImagePicker: false,
          storedPhotos: [
            .init(id: "1", uiImage: .add, imageUrl: .some(.init(string: "URL")!)),
            .init(id: "2", uiImage: .actions, imageUrl: .some(.init(string: "URL")!))
          ],
          coordinateFromImagePicker: nil,
          dateFromImagePicker: nil
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
            postalCode: "1243", city: "Berlin"
          )
        )
      ),
      reducer: reportReducer,
      environment: ReportEnvironment(
        mainQueue: .immediate,
        backgroundQueue: .immediate,
        locationManager: LocationManager.unimplemented(),
        placeService: .noop,
        regulatoryOfficeMapper: .noop,
        fileClient: fileClient,
        wegliService: wegliService,
        date: Date.init,
        imagesUploadClient: imagesUploadClient
      )
    )
    
    await store.send(.uploadImages) {
      $0.uploadProgressState = "Uploading images ..."
      $0.isUploadingNotice = true
    }
    await store.receive(.uploadImagesResponse(.success(responses))) {
      $0.uploadedImagesIds = ["111", "222"]
    }
    await store.receive(.composeNoticeAndSend) {
      $0.uploadProgressState = "Sending notice ..."
    }
    await store.receive(.composeNoticeResponse(.success(.mock))) {
      $0.isUploadingNotice = false
      $0.alert = .reportSent
      $0.uploadedImagesIds = []
      $0.uploadProgressState = nil
      $0.uploadedNoticeID = Notice.mock.id
    }
    await didRemoveImageItems.withValue({ value in
      XCTAssertTrue(value)
    })
    
  }
}
