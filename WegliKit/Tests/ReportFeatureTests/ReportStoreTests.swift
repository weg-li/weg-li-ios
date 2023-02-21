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
  
  var report: ReportDomain.State!
  
  override func setUp() {
    super.setUp()
    
    report = ReportDomain.State(
      uuid: fixedUUID,
      images: ImagesViewDomain.State(
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
  
  func test_updateDate_shouldUpdateState() async {
    let newDate = Date(timeIntervalSinceReferenceDate: 0)
    
    let store = TestStore(
      initialState: report,
      reducer: ReportDomain(),
      prepareDependencies: { values in
        values.continuousClock = ImmediateClock()
        values.locationManager = .unimplemented
        values.placesServiceClient = .noop
        values.regulatoryOfficeMapper = .noop
        values.fileClient = .noop
        values.apiService = .noop
      }
    )
    
    await store.send(.set(\.$date, newDate)) {
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
      reducer: ReportDomain(),
      prepareDependencies: { values in
        values.continuousClock = ImmediateClock()
        values.locationManager = .unimplemented
        values.placesServiceClient = .noop
        values.regulatoryOfficeMapper = .noop
        values.fileClient = fileClient
        values.apiService = .noop
      }
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
      
  func test_updateImages_shouldTriggerAddressResolve() async {
    let locationObserver = AsyncStream<LocationManager.Action>.streamWithContinuation()
  
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
      reducer: ReportDomain()
    )
    let clock = TestClock()
    store.dependencies.continuousClock = clock
    store.dependencies.locationManager = .unimplemented
    store.dependencies.locationManager.authorizationStatus = { .authorizedAlways }
    store.dependencies.locationManager.delegate = { locationObserver.stream }
    store.dependencies.locationManager.locationServicesEnabled = { true }
    store.dependencies.placesServiceClient.placemarks = { _ in [expectedAddress] }
    store.dependencies.regulatoryOfficeMapper = .live()
    store.dependencies.fileClient = .noop
    store.dependencies.apiService = .noop
    store.dependencies.textRecognitionClient.recognizeText = { _ in [TextItem(id: "", text: "")] }
    
    
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
    await clock.advance(by: .seconds(1))
    
    await store.receive(.images(.textRecognitionCompleted(.success([TextItem(id: "", text: "")])))) {
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
  }
  
  func test_submitButtonTap_createsMail_andPresentsMailView() async {
    let image = UIImage(systemName: "pencil")!
    let store = TestStore(
      initialState: ReportDomain.State(
        uuid: fixedUUID,
        images: ImagesViewDomain.State(
          showImagePicker: false,
          storedPhotos: [PickerImageResult(uiImage: image)!],
          coordinateFromImagePicker: .zero
        ),
        contactState: .empty,
        district: districs[0],
        date: fixedDate,
        description: .init(),
        location: LocationDomain.State(
          locationOption: .currentLocation,
          isMapExpanded: false,
          isResolvingAddress: false,
          resolvedAddress: .init(
            street: ReportDomain.State.preview.contactState.contact.address.street,
            postalCode: ReportDomain.State.preview.contactState.contact.address.postalCode,
            city: ReportDomain.State.preview.contactState.contact.address.city
          )
        )
      ),
      reducer: ReportDomain()
    )
    store.dependencies.mailComposeClient.canSendMail = { true }
    
    await store.send(.mail(.submitButtonTapped)) {
      $0.mail.mail.address = "Anzeige@bowi.berlin.de"
      $0.mail.mail.body = $0.createMailBody()
    }
    await store.receive(.mail(.presentMailContentView(true))) {
      $0.mail.isPresentingMailContent = true
    }
  }
  
  func test_submitButtonTap_createsMail_butShowsError() async {
    let image = UIImage(systemName: "pencil")!
    let store = TestStore(
      initialState: ReportDomain.State(
        uuid: fixedUUID,
        images: ImagesViewDomain.State(
          showImagePicker: false,
          storedPhotos: [PickerImageResult(uiImage: image)!],
          coordinateFromImagePicker: .zero
        ),
        contactState: .empty,
        district: districs[0],
        date: fixedDate,
        description: .init(),
        location: LocationDomain.State(
          locationOption: .currentLocation,
          isMapExpanded: false,
          isResolvingAddress: false,
          resolvedAddress: .init(
            street: ReportDomain.State.preview.contactState.contact.address.street,
            postalCode: ReportDomain.State.preview.contactState.contact.address.postalCode,
            city: ReportDomain.State.preview.contactState.contact.address.city
          )
        )
      ),
      reducer: ReportDomain()
    )
    store.dependencies.mailComposeClient.canSendMail = { false }
    
    await store.send(.mail(.submitButtonTapped)) {
      $0.alert = .noMailAccount
    }
  }
  
  func test_locationOptionCurrentLocation_shouldTriggerResolveLocation_andSetDistrict() async {
    let store = TestStore(
      initialState: report,
      reducer: ReportDomain()
    )
    store.dependencies.regulatoryOfficeMapper = .live(districs)
    
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
  
  func test_locationOptionCurrentLocation_shouldPresentOfflineError_whenClientHasNoInternetConnection() async {
    let coordinate = CLLocationCoordinate2D(latitude: 31.31, longitude: 12.12)
    
    var state: ReportDomain.State = report
    state.isNetworkAvailable = false
    state.location.pinCoordinate = coordinate
    
    let store = TestStore(
      initialState: state,
      reducer: ReportDomain()
    )
    store.dependencies.regulatoryOfficeMapper = .live(districs)
        
    await store.send(.images(.setImageCoordinate(coordinate))) {
      $0.images.pickerResultCoordinate = coordinate
      $0.location.pinCoordinate = coordinate
      $0.location.region = .init(center: .init(coordinate), span: .init(latitudeDelta: 0.005, longitudeDelta: 0.005))
      
      $0.alert = .init(
        title: .init("Keine Internetverbindung"),
        message: .init("Verbinde dich mit dem Internet um eine Adresse für die Fotos zu ermitteln"),
        buttons: [
          .cancel(.init("Abbrechen")),
          .default(.init("Wiederholen"), action: .send(.location(.resolveLocation((state.location.pinCoordinate!)))))
        ]
      )
    }
  }
  
  func test_imagesAction_shouldNotTriggerResolveLocation_whenLocationisNotMappable() async {
    let store = TestStore(
      initialState: report,
      reducer: ReportDomain()
    )
    store.dependencies.regulatoryOfficeMapper = .live(districs)
    
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
      initialState: ReportDomain.State(
        uuid: fixedUUID,
        images: ImagesViewDomain.State(
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
      reducer: ReportDomain()
    )
    store.dependencies.regulatoryOfficeMapper = .live(districs)
    
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
      initialState: ReportDomain.State(
        uuid: fixedUUID,
        images: ImagesViewDomain.State(
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
      reducer: ReportDomain()
    )
    store.dependencies.regulatoryOfficeMapper = .live(districs)
    
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
  
  func test_removeImage_shouldSetResolvedCoordinateToNil_whenPhotosIsEmptyAfterDelete() async {
    let images = [
      PickerImageResult(
        id: "123",
        uiImage: UIImage(systemName: "pencil")!
      )
    ]
    let coordinate = CLLocationCoordinate2D(latitude: 23.21, longitude: 67.76)
    let testDate = { Date(timeIntervalSinceReferenceDate: 0) }
    
    let store = TestStore(
      initialState: ReportDomain.State(
        uuid: fixedUUID,
        images: ImagesViewDomain.State(
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
      reducer: ReportDomain()
    )
    store.dependencies.regulatoryOfficeMapper = .live(districs)
    store.dependencies.continuousClock = ImmediateClock()
    
    
    await store.send(.images(.image(id: "123", action: .onRemovePhotoButtonTapped)))
    await store.receive(.images(.justSetPhotos([]))) {
      $0.images.storedPhotos = []
    }
  }
  
  func test_resetDataButtonTap_shouldPresentAnAlert() async {
    let store = TestStore(
      initialState: ReportDomain.State(
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
      reducer: ReportDomain()
    )
    
    await store.send(.onResetButtonTapped) {
      $0.alert = .resetReportAlert
    }
  }
  
  func test_setShowContact_shouldPresentAnAlert() async {
    let store = TestStore(
      initialState: ReportDomain.State(
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
      reducer: ReportDomain()
    )
    
    await store.send(.set(\.$showEditContact, true)) {
      $0.showEditContact = true
    }
  }
  
  func test_setShowDescription_shouldPresentAnAlert() async {
    let store = TestStore(
      initialState: ReportDomain.State(
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
      reducer: ReportDomain()
    )
    
    await store.send(.set(\.$showEditDescription, true)) {
      $0.showEditDescription = true
    }
  }
  
  func test_selectedLicensePlate_shouldSetDescriptionDomainState() async {
    let store = TestStore(
      initialState: ReportDomain.State(
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
      reducer: ReportDomain()
    )
    
    let item = TextItem(id: "123", text: "B-MB 3000")
    await store.send(.images(.selectedTextItem(item))) {
      $0.description.licensePlateNumber = item.text
    }
  }
  
  func test_action_onSubmitButtonTapped() async {
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
    
    var wegliService = APIService.noop
    wegliService.postNotice = { _ in .mock }
    
    let didRemoveImageItems = ActorIsolated(false)
    var fileClient = FileClient.noop
    fileClient.removeItem = { @Sendable _ in
      await didRemoveImageItems.setValue(true)
      return ()
    }
    
    var state: ReportDomain.State = ReportDomain.State(
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
    )
    state.alwaysSendNotice = true
    
    let store = TestStore(
      initialState: state,
      reducer: ReportDomain(),
      prepareDependencies: { values in
        values.continuousClock = ImmediateClock()
        values.locationManager = .unimplemented
        values.placesServiceClient = .noop
        values.regulatoryOfficeMapper = .noop
        values.fileClient = fileClient
        values.apiService = wegliService
        values.imagesUploadClient = imagesUploadClient
      }
    )
    store.dependencies.apiService.submitNotice = { _ in .mock }
    store.dependencies.feedbackGenerator.notify = { _ in }
    
    await store.send(.onSubmitButtonTapped) {
      $0.isSubmittingNotice = true
    }
    await store.receive(.uploadImages)
    await store.receive(.uploadImagesResponse(.success(responses))) {
      $0.uploadedImagesIds = ["111", "222"]
    }
    await store.receive(.composeNotice)
    
    await store.receive(.submitNoticeResponse(.success(.mock))) {
      $0.isSubmittingNotice = false
      $0.alert = .reportSent
      $0.uploadedImagesIds = []
    }
    await didRemoveImageItems.withValue({ value in
      XCTAssertTrue(value)
    })
    
  }
}
