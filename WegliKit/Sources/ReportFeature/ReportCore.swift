// Created for weg-li in 2021.

import ApiClient
import ComposableArchitecture
import ComposableCoreLocation
import ContactFeature
import DescriptionFeature
import FileClient
import Helper
import ImagesFeature
import ImagesUploadClient
import L10n
import LocationFeature
import MailFeature
import MessageUI
import PathMonitorClient
import PlacesServiceClient
import RegulatoryOfficeMapper
import SharedModels
import SwiftUI
import UIApplicationClient

// MARK: - Report Core

public struct ReportState: Equatable {
  public var id: String
  public var images: ImagesViewState
  public var contactState: ContactState
  public var district: District?
  
  public var date: Date
  public var description: DescriptionState
  public var location: LocationViewState
  public var mail: MailViewState
  
  public var alert: AlertState<ReportAction>?
  
  public var showEditDescription = false
  public var showEditContact = false
  
  public var apiToken = ""
  
  public var uploadedImagesIds: [String] = []
  public var uploadProgressState: String?
  
  public var isPhotosValid: Bool { !images.storedPhotos.isEmpty }
  public var isContactValid: Bool { contactState.isValid }
  public var isDescriptionValid: Bool { description.isValid }
  public var isLocationValid: Bool { location.resolvedAddress.isValid }
  public var isResetButtonDisabled: Bool {
    location.resolvedAddress == .init()
      && images.storedPhotos.isEmpty
      && description == .init()
  }

  public var isNetworkAvailable = true
  public var isUploadingNotice = false
  
  public var uploadedNoticeID: String?
  
  public func isModified() -> Bool {
    district != nil
      || isPhotosValid
      || contactState.isValid
      || location != .init()
      || description != .init()
  }
  
  public var isReportValid: Bool {
    images.isValid
      && contactState.isValid
      && description.isValid
      && location.resolvedAddress.isValid
  }
  
  internal init(
    id: String,
    images: ImagesViewState,
    contactState: ContactState,
    district: District? = nil,
    date: Date,
    description: DescriptionState,
    location: LocationViewState,
    mail: MailViewState,
    alert: AlertState<ReportAction>? = nil,
    showEditDescription: Bool = false,
    showEditContact: Bool = false,
    apiToken: String = "",
    uploadedImagesIds: [String] = [],
    uploadProgressState: String? = nil,
    isNetworkAvailable: Bool = true,
    isUploadingNotice: Bool = false
  ) {
    self.id = id
    self.images = images
    self.contactState = contactState
    self.district = district
    self.date = date
    self.description = description
    self.location = location
    self.mail = mail
    self.alert = alert
    self.showEditDescription = showEditDescription
    self.showEditContact = showEditContact
    self.apiToken = apiToken
    self.uploadedImagesIds = uploadedImagesIds
    self.uploadProgressState = uploadProgressState
    self.isNetworkAvailable = isNetworkAvailable
    self.isUploadingNotice = isUploadingNotice
  }
}

public extension ReportState {
  init(
    uuid: @escaping () -> UUID,
    images: ImagesViewState,
    contactState: ContactState,
    district: District? = nil,
    date: () -> Date,
    description: DescriptionState = DescriptionState(),
    location: LocationViewState = LocationViewState(),
    mail: MailViewState = MailViewState()
  ) {
    self.id = uuid().uuidString
    self.images = images
    self.contactState = contactState
    self.district = district
    self.date = date()
    self.description = description
    self.location = location
    self.mail = mail
  }
}

public enum ReportAction: BindableAction, Equatable {
  case binding(BindingAction<ReportState>)
  case onAppear
  case images(ImagesViewAction)
  case contact(ContactStateAction)
  case description(DescriptionAction)
  case location(LocationViewAction)
  case mail(MailViewAction)
  case mapAddressToDistrict(Address)
  case mapDistrictFinished(Result<District, RegularityOfficeMapError>)
  case resetButtonTapped
  case resetConfirmButtonTapped
  case setShowEditDescription(Bool)
  case setShowEditContact(Bool)
  case dismissAlert
  case setDate(Date)
  case uploadImages
  case uploadImagesResponse(Result<[ImageUploadResponse], NSError>)
  case composeNoticeAndSend
  case composeNoticeResponse(Result<Notice, ApiError>)
  case editNoticeInBrowser
}

public struct ReportEnvironment {
  public init(
    mainQueue: AnySchedulerOf<DispatchQueue>,
    backgroundQueue: AnySchedulerOf<DispatchQueue>,
    mapAddressQueue: AnySchedulerOf<DispatchQueue> = mapperQueue.eraseToAnyScheduler(),
    locationManager: LocationManager,
    placeService: PlacesServiceClient,
    regulatoryOfficeMapper: RegulatoryOfficeMapper,
    fileClient: FileClient,
    wegliService: WegliAPIService,
    uiApplicationClient: UIApplicationClient = .live,
    date: @escaping () -> Date,
    pathMonitorClient: PathMonitorClient = .live(queue: .main),
    imagesUploadClient: ImagesUploadClient = .live()
  ) {
    self.mainQueue = mainQueue
    self.backgroundQueue = backgroundQueue
    self.mapAddressQueue = mapAddressQueue
    self.locationManager = locationManager
    self.placeService = placeService
    self.regulatoryOfficeMapper = regulatoryOfficeMapper
    self.fileClient = fileClient
    self.pathMonitorClient = pathMonitorClient
    self.imagesUploadClient = imagesUploadClient
    self.wegliService = wegliService
    self.uiApplicationClient = uiApplicationClient
    
    self.date = date
  }
  
  public var mainQueue: AnySchedulerOf<DispatchQueue>
  public var backgroundQueue: AnySchedulerOf<DispatchQueue>
  public var mapAddressQueue: AnySchedulerOf<DispatchQueue>
  public var locationManager: LocationManager
  public var placeService: PlacesServiceClient
  public var regulatoryOfficeMapper: RegulatoryOfficeMapper
  public let fileClient: FileClient
  public let pathMonitorClient: PathMonitorClient
  public let imagesUploadClient: ImagesUploadClient
  public let wegliService: WegliAPIService
  public let uiApplicationClient: UIApplicationClient
  public var date: () -> Date
  
  public var canSendMail: () -> Bool = MFMailComposeViewController.canSendMail
  
  let debounce = 0.5
  let postalCodeMinumimCharacters = 5
}

struct ObserveConnectionIdentifier: Hashable {}

/// Combined reducer that is used in the ReportView and combing descending reducers.
public let reportReducer = Reducer<ReportState, ReportAction, ReportEnvironment>.combine(
  imagesReducer.pullback(
    state: \.images,
    action: /ReportAction.images,
    environment: {
      ImagesViewEnvironment(
        mainQueue: $0.mainQueue,
        backgroundQueue: $0.backgroundQueue,
        cameraAccessClient: .live(),
        photoLibraryAccessClient: .live(),
        textRecognitionClient: .live
      )
    }
  ),
  descriptionReducer.pullback(
    state: \.description,
    action: /ReportAction.description,
    environment: {
      DescriptionEnvironment(
        mainQueue: $0.mainQueue,
        backgroundQueue: $0.backgroundQueue,
        fileClient: $0.fileClient
      )
    }
  ),
  contactViewReducer.pullback(
    state: \.contactState,
    action: /ReportAction.contact,
    environment: { _ in ContactEnvironment() }
  ),
  locationReducer.pullback(
    state: \.location,
    action: /ReportAction.location,
    environment: {
      LocationViewEnvironment(
        locationManager: $0.locationManager,
        placeService: $0.placeService,
        uiApplicationClient: .live,
        mainRunLoop: $0.mainQueue
      )
    }
  ),
  mailViewReducer.pullback(
    state: \.mail,
    action: /ReportAction.mail,
    environment: { _ in MailViewEnvironment() }
  ),
  Reducer { state, action, environment in
    struct LocationManagerId: Hashable {}
    struct DebounceID: Hashable {}
    
    switch action {
    case .binding:
      return .none
      
    case .onAppear:
      return .none
  
    // Triggers district mapping after geoAddress is stored.
    case let .mapAddressToDistrict(input):
      return environment.regulatoryOfficeMapper
        .mapAddress(address: input, on: environment.mapAddressQueue)
        .receive(on: environment.mainQueue)
        .catchToEffect()
        .map(ReportAction.mapDistrictFinished)
        .eraseToEffect()
        .debounce(
          id: DebounceID(),
          for: .seconds(environment.debounce),
          scheduler: environment.mainQueue
        )
      
    case let .mapDistrictFinished(.success(district)):
      state.district = district
      return .none
      
    case let .mapDistrictFinished(.failure(error)):
      // present alert maybe?
      debugPrint(error.message)
      return .none
      
    case let .images(imageViewAction):
      switch imageViewAction {
      // After the images coordinate was set trigger resolve location and map to district.
      case let .setImageCoordinate(coordinate):
        guard let coordinate = coordinate, !state.images.storedPhotos.isEmpty else {
          state.alert = .noPhotoCoordinate
          return .none
        }
        
        state.location.region = CoordinateRegion(center: coordinate)
        state.images.pickerResultCoordinate = coordinate
        state.location.pinCoordinate = coordinate
        
        guard state.isNetworkAvailable else {
          state.alert = .noInternetConnection(coordinate: state.location.pinCoordinate!)
          return .none
        }
        
        return Effect(value: ReportAction.location(.resolveLocation(coordinate)))
        
      case .setPhotos:
        return .none
        
      case let .setImageCreationDate(date):
        // set report date from selected photos
        state.date = date ?? Date()
        return .none
      
      // Handle single image remove action to reset map annotations and reset valid state.
      case .image(_, .removePhoto):
        if state.images.storedPhotos.isEmpty, state.location.locationOption == .fromPhotos {
          state.images.pickerResultCoordinate = nil
          state.location.pinCoordinate = nil
          state.location.resolvedAddress = .init()
          state.date = environment.date()
        }
        return .none
        
      case let .selectedTextItem(textItem):
        state.description.licensePlateNumber = textItem.text.uppercased()
        return .none
        
      default:
        return .none
      }
      
    case let .location(locationAction):
      switch locationAction {
      // Trigger district mapping after address is resolved.
      case let .resolveAddressFinished(.success(resolvedAddresses)):
        guard let address = resolvedAddresses.first else {
          return .none
        }
        return Effect(value: ReportAction.mapAddressToDistrict(address))
        
      case let .resolveAddressFinished(.failure(error)):
        state.alert = .addressResolveFailed(error: error)
        return .none
        
      // Handle manual address entering to trigger district mapping.
      case let .updateGeoAddressPostalCode(postalCode):
        guard postalCode.count == environment.postalCodeMinumimCharacters, postalCode.isNumeric else {
          return .none
        }
        return Effect(value: ReportAction.mapAddressToDistrict(state.location.resolvedAddress))
        
      case let .updateGeoAddressCity(city):
        return Effect(value: ReportAction.mapAddressToDistrict(state.location.resolvedAddress))
        
      case let .setLocationOption(option) where option == .fromPhotos:
        if !state.images.storedPhotos.isEmpty, let coordinate = state.images.pickerResultCoordinate {
          return Effect(value: .location(.resolveLocation(coordinate)))
        } else {
          return .none
        }
        
      case let .setPinCoordinate(coordinate):
        guard let coordinate = coordinate, state.location.locationOption == .currentLocation else { return .none }
        return Effect(value: .location(.resolveLocation(coordinate)))
        
      default:
        return .none
      }
      
    // Compose mail when send mail button was tapped.
    case .mail(.submitButtonTapped):
      guard environment.canSendMail() else {
        state.alert = .noMailAccount
        return .none
      }
      
      guard let district = state.district else {
        return .none
      }
      state.mail.mail.address = district.email
      state.mail.mail.body = state.createMailBody()
      state.mail.mail.attachmentData = state.images.storedPhotos
        .compactMap { $0?.imageUrl }
        .compactMap { try? Data(contentsOf: $0) }
      return Effect(value: ReportAction.mail(.presentMailContentView(true)))
  
    case .mail:
      return .none
      
    case .contact, .description:
      return .none
      
    case .resetButtonTapped:
      state.alert = .resetReportAlert
      return .none
      
    case .resetConfirmButtonTapped:
      // Reset report will be handled in the homeReducer
      return Effect(value: .dismissAlert)
      
    case let .setShowEditDescription(value):
      state.showEditDescription = value
      return .none
      
    case let .setShowEditContact(value):
      state.showEditContact = value
      return .none
      
    case .dismissAlert:
      state.alert = nil
      return .none
      
    case let .setDate(date):
      state.date = date
      return .none
      
    case .uploadImages:
      guard state.isNetworkAvailable else {
        state.alert = .init(
          title: .init("Keine Internetverbindung"),
          message: .init("Verbinde dich mit dem Internet um die Meldung hochzuladen"),
          buttons: [
            .cancel(.init(L10n.cancel)),
            .default(.init("Wiederholen"), action: .send(.uploadImages))
          ]
        )
        return .none
      }
      
      let imageUploadRequests = state.images.imageStates.map {
        UploadImageRequest(pickerResult: $0.image)
      }
      
      state.isUploadingNotice = true
      state.uploadProgressState = "Uploading images ..."
      
      return environment.imagesUploadClient.uploadImages(imageUploadRequests)
        .subscribe(on: environment.backgroundQueue)
        .receive(on: environment.mainQueue)
        .map(ReportAction.uploadImagesResponse)
        .eraseToEffect()
      
    case let .uploadImagesResponse(.success(imageInputFromUpload)):
      state.uploadedImagesIds = imageInputFromUpload.map(\.signedId)
      return Effect(value: .composeNoticeAndSend)
      
    case let .uploadImagesResponse(.failure(error)):
      return Effect(value: .composeNoticeResponse(.failure(ApiError(error: error))))
      
    case .composeNoticeAndSend:
      var notice = NoticeInput(state)
      notice.photos = state.uploadedImagesIds
      state.isUploadingNotice = true
      
      state.uploadProgressState = "Sending notice ..."
      
      return environment.wegliService.postNotice(notice)
        .receive(on: environment.mainQueue)
        .map(ReportAction.composeNoticeResponse)
        .eraseToEffect()
      
    case let .composeNoticeResponse(.success(response)):
      state.isUploadingNotice = false
      state.alert = .reportSent
      state.uploadedImagesIds.removeAll()
      state.uploadProgressState = nil
      
      state.uploadedNoticeID = response.token
      
      let imageURLs = state.images.storedPhotos.compactMap { $0?.imageUrl }
      return .fireAndForget {
        imageURLs.forEach {
          environment.fileClient.removeItem($0)
            .ignoreFailure()
            .eraseToEffect()
        }
      }
      
    case let .composeNoticeResponse(.failure(error)):
      state.isUploadingNotice = false
      state.alert = .sendNoticeFailed(error: error)
      state.uploadProgressState = nil
      return .none
      
    case .editNoticeInBrowser:
      guard let id = state.uploadedNoticeID else {
        return .none
      }
      let editURL = URL(string: "https://www.weg.li/notices/\(id)/edit")!
      return environment.uiApplicationClient
        .open(editURL, [:])
        .fireAndForget()
    }
  }
)
.binding()
.onChange(of: \.contactState.contact) { contact, _, _, environment in
  struct SaveDebounceId: Hashable {}
  
  return environment.fileClient
    .saveContactSettings(contact, on: environment.backgroundQueue)
    .fireAndForget()
    .debounce(id: SaveDebounceId(), for: .seconds(1), scheduler: environment.mainQueue)
}

// MARK: - Helper

public extension ReportState {
  static let preview = ReportState(
    uuid: UUID.init,
    images: .init(
      showImagePicker: false,
      storedPhotos: [PickerImageResult(uiImage: UIImage(systemName: "trash")!)!] // swiftlint:disable:this force_unwrapping
    ),
    contactState: .preview,
    district: District(
      name: "Hamburg St. Pauli",
      zip: "20099",
      email: "mail@stpauli.de",
      latitude: 53.53,
      longitude: 13.13,
      personalEmail: true
    ),
    date: { Date(timeIntervalSince1970: 1_580_624_207) },
    description: .init(
      licensePlateNumber: "       ",
      selectedColor: 3,
      selectedBrand: .init("Opel"),
      selectedDuration: 5,
      selectedCharge: .init(id: "1", text: "Parken auf dem Radweg", isFavorite: true, isSelected: false),
      blockedOthers: true
    )
  )
}

public extension AlertState where Action == ReportAction {
  static func noInternetConnection(coordinate: CLLocationCoordinate2D) -> Self {
    Self(
      title: .init("Keine Internetverbindung"),
      message: .init("Verbinde dich mit dem Internet um eine Adresse für die Fotos zu ermitteln"),
      buttons: [
        .cancel(.init(L10n.cancel)),
        .default(.init("Wiederholen"), action: .send(.location(.resolveLocation(coordinate))))
      ]
    )
  }
  
  static func addressResolveFailed(error: PlacesServiceError) -> Self {
    Self(
      title: .init("Addresse konnte nicht ermittelt werden"),
      message: .init(error.message),
      buttons: [.cancel(.init(L10n.cancel))]
    )
  }
  
  static let resetReportAlert = Self(
    title: TextState(L10n.Report.Alert.title),
    primaryButton: .destructive(
      TextState(L10n.Report.Alert.reset),
      action: .send(.resetConfirmButtonTapped)
    ),
    secondaryButton: .cancel(
      .init(L10n.cancel),
      action: .send(.dismissAlert)
    )
  )
  
  static let reportSent = Self(
    title: .init("Meldung hinzugefügt"),
    message: .init("Meldung wurde deinem Account hinzugefügt. Gehe zu `weg.li` um die Anzeige abzusenden (z.Z. noch nicht über die App möglich)"),
    buttons: [
      .default(.init("Ok"), action: .send(.resetConfirmButtonTapped)),
      .default(.init("Gehe zu `weg.li`"), action: .send(.editNoticeInBrowser))
    ]
  )
  
  static func sendNoticeFailed(error: ApiError) -> Self {
    Self(
      title: .init("Meldung konnte nicht gesendet werden"),
      message: .init("Fehler: \(error.message)"),
      buttons: [
        .default(.init(verbatim: "Erneut senden"), action: .send(.composeNoticeAndSend)),
        .cancel(.init(verbatim: L10n.cancel), action: .send(.dismissAlert))
      ]
    )
  }
  
  static let noMailAccount = Self(
    title: TextState("Fehler"),
    message: TextState("Mail kann nicht gesendet werden, da kein Account gefunden werden konnte"),
    buttons: [
      .default(
        .init("Meldung kopieren"),
        action: .send(.mail(.copyMailBody))
      ),
      .default(
        .init("Addresse kopieren"),
        action: .send(.mail(.copyMailToAddress))
      ),
      .cancel(
        .init(L10n.cancel),
        action: .send(.dismissAlert)
      )
    ]
  )
  
  static let noPhotoCoordinate = Self(
    title: TextState(L10n.Location.Alert.noCoordinate)
  )
}

public let mapperQueue = DispatchQueue(
  label: "li.weg.iosclient.RegulatoryOfficeMapper",
  qos: .userInitiated,
  attributes: .concurrent
)

public extension FileClient {
  func loadNotices(decoder: JSONDecoder = .noticeDecoder) -> Effect<Result<[Notice], NSError>, Never> {
    load([Notice].self, from: noticesFileName, with: decoder)
  }
  
  func saveNotices(
    _ notices: [Notice]?,
    on queue: AnySchedulerOf<DispatchQueue>,
    encoder: JSONEncoder = .noticeEncoder
  ) -> Effect<Never, Never> {
    guard let notices = notices else {
      return .none
    }
    return save(notices, to: noticesFileName, on: queue, with: encoder)
  }
}

let noticesFileName = "notices"

public extension SharedModels.NoticeInput {
  init(_ reportState: ReportState) {
    self.init(
      token: reportState.id,
      status: "open",
      street: reportState.location.resolvedAddress.street,
      city: reportState.location.resolvedAddress.city,
      zip: reportState.location.resolvedAddress.postalCode,
      latitude: reportState.location.pinCoordinate?.latitude ?? 0,
      longitude: reportState.location.pinCoordinate?.longitude ?? 0,
      registration: reportState.description.licensePlateNumber,
      brand: reportState.description.selectedBrand?.title ?? "",
      color: DescriptionState.colors[reportState.description.selectedColor].key,
      charge: reportState.description.selectedCharge?.text ?? "",
      date: reportState.date,
      duration: Int64(reportState.description.selectedDuration),
      severity: nil,
      note: reportState.description.note,
      createdAt: .now,
      updatedAt: .now,
      sentAt: .now,
      vehicleEmpty: reportState.description.vehicleEmpty,
      hazardLights: reportState.description.hazardLights,
      expiredTuv: reportState.description.expiredTuv,
      expiredEco: reportState.description.expiredEco,
      photos: []
    )
  }
}

public extension SharedModels.Notice {
  init(_ reportState: ReportState) {
    self.init(
      token: reportState.id,
      status: "open",
      street: reportState.location.resolvedAddress.street,
      city: reportState.location.resolvedAddress.city,
      zip: reportState.location.resolvedAddress.postalCode,
      latitude: reportState.location.pinCoordinate?.latitude ?? 0,
      longitude: reportState.location.pinCoordinate?.longitude ?? 0,
      registration: reportState.description.licensePlateNumber,
      brand: reportState.description.selectedBrand?.title ?? "",
      color: DescriptionState.colors[reportState.description.selectedColor].key,
      charge: reportState.description.selectedCharge?.text ?? "",
      date: reportState.date,
      duration: Int64(reportState.description.selectedDuration),
      severity: nil,
      note: reportState.description.note,
      createdAt: .now,
      updatedAt: .now,
      sentAt: .now,
      photos: []
    )
  }
  
  static let placeholder = Self(.preview)
}
