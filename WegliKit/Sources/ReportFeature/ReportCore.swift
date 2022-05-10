// Created for weg-li in 2021.

import ComposableArchitecture
import ComposableCoreLocation
import ContactFeature
import DescriptionFeature
import Helper
import L10n
import LocationFeature
import ImagesFeature
import MailFeature
import MessageUI
import PathMonitorClient
import PlacesServiceClient
import RegulatoryOfficeMapper
import SharedModels
import SwiftUI
import FileClient

// MARK: - Report Core

public struct Report: Codable, Equatable {
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
  
  public var isPhotosValid: Bool { !images.storedPhotos.isEmpty }
  public var isContactValid: Bool { contactState.isValid }
  public var isDescriptionValid: Bool { description.isValid }
  public var isLocationValid: Bool { location.resolvedAddress.isValid }
  public var isResetButtonDisabled: Bool {
    location.resolvedAddress == .init()
      && images.storedPhotos.isEmpty
      && description == .init()
  }
  public var isInternetConnectionAvailable = true
  
  public func isModified() -> Bool {
    district != nil
    || isPhotosValid
    || contactState.isValid
    || location != .init()
    || description != .init()
  }
  
  public init(
    uuid: @escaping () -> UUID,
    images: ImagesViewState,
    contactState: ContactState,
    district: District? = nil,
    date: () -> Date,
    description: DescriptionState = DescriptionState(),
    location: LocationViewState = LocationViewState(),
    mail: MailViewState = MailViewState()
  ) {
    id = uuid().uuidString
    self.images = images
    self.contactState = contactState
    self.district = district
    self.date = date()
    self.description = description
    self.location = location
    self.mail = mail
  }
  
  private enum CodingKeys: String, CodingKey {
    case id, images, contactState, district, date, description, location, mail
  }
}

public enum ReportAction: Equatable {
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
  case observeConnection
  case observeConnectionResponse(NetworkPath)
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
    date: @escaping () -> Date,
    pathMonitorClient: PathMonitorClient = .live(queue: .main)
  ) {
    self.mainQueue = mainQueue
    self.backgroundQueue = backgroundQueue
    self.mapAddressQueue = mapAddressQueue
    self.locationManager = locationManager
    self.placeService = placeService
    self.regulatoryOfficeMapper = regulatoryOfficeMapper
    self.fileClient = fileClient
    self.date = date
    self.pathMonitorClient = pathMonitorClient
  }
  
  public var mainQueue: AnySchedulerOf<DispatchQueue>
  public var backgroundQueue: AnySchedulerOf<DispatchQueue>
  public var mapAddressQueue: AnySchedulerOf<DispatchQueue>
  public var locationManager: LocationManager
  public var placeService: PlacesServiceClient
  public var regulatoryOfficeMapper: RegulatoryOfficeMapper
  public let fileClient: FileClient
  public let pathMonitorClient: PathMonitorClient
  public var date: () -> Date
  
  public var canSendMail: () -> Bool = MFMailComposeViewController.canSendMail
  
  let debounce = 0.5
  let postalCodeMinumimCharacters = 5
}

struct ObserveConnectionIdentifier: Hashable {}

/// Combined reducer that is used in the ReportView and combing descending reducers.
public let reportReducer = Reducer<Report, ReportAction, ReportEnvironment>.combine(
  imagesReducer.pullback(
    state: \.images,
    action: /ReportAction.images,
    environment: {
      ImagesViewEnvironment(
        mainQueue: $0.mainQueue,
        backgroundQueue: $0.backgroundQueue,
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
    case .onAppear:
      return Effect(value: .observeConnection)
  
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
        guard let coordinate = coordinate else {
          state.alert = .noPhotoCoordinate
          return .none
        }
        
        state.location.region = CoordinateRegion(center: coordinate)
        state.images.pickerResultCoordinate = coordinate
        state.location.pinCoordinate = coordinate
        
        guard state.isInternetConnectionAvailable else {
          state.alert = .init(
            title: .init("Keine Internetverbindung"),
            message: .init("Verbinde dich mit dem Internet um eine Adresse für die Fotos zu ermitteln"),
            buttons: [
              .cancel(.init(L10n.cancel)),
              .default(.init("Wiederholen"), action: .send(.location(.resolveLocation(state.location.pinCoordinate!))))
            ]
          )
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
      case .image(_ , .removePhoto):
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
        debugPrint(error.localizedDescription)
        state.alert = .init(
          title: .init("Addresse konnte nicht ermittelt werden"),
          message: .init(error.localizedDescription),
          buttons: [.cancel(.init(L10n.cancel))])
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
      
    case .observeConnection:
      return Effect(environment.pathMonitorClient.networkPathPublisher)
        .receive(on: environment.mainQueue)
        .eraseToEffect()
        .map(ReportAction.observeConnectionResponse)
        .cancellable(id: ObserveConnectionIdentifier())
      
    case let .observeConnectionResponse(networkPath):
      state.isInternetConnectionAvailable = networkPath.status == .satisfied
      return .none
    }
  }
)
.onChange(of: \.contactState.contact) { contact, state, _, environment in
  struct SaveDebounceId: Hashable {}
  
  return environment.fileClient
    .saveContactSettings(contact, on: environment.backgroundQueue)
    .fireAndForget()
    .debounce(id: SaveDebounceId(), for: .seconds(1), scheduler: environment.mainQueue)
}

// MARK: - Helper
public extension Report {
  static var preview: Report {
    Report(
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
      date: { Date(timeIntervalSince1970: 1580624207) },
      description: .init(
        licensePlateNumber: "HH-ST-PAULI",
        selectedColor: 3,
        selectedBrand: .init("Opel"),
        selectedDuration: 5,
        selectedCharge: .init(id: "1", text: "Parken auf dem Radweg", isFavorite: true, isSelected: false),
        blockedOthers: true
      )
    )
  }
}

public extension AlertState where Action == ReportAction {
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
  
  static let noMailAccount = Self(
    title: TextState("Fehler"),
    message: TextState("Mail kann nicht gesendet werden, da kein Account gefunden werden konnte"),
    buttons: [
      .default(
        .init("Anzeige kopieren"),
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
  func loadReports() -> Effect<Result<[Report], NSError>, Never> {
    self.load([Report].self, from: reportsFileName)
  }
  
  func saveReports(
    _ reports: [Report], on queue: AnySchedulerOf<DispatchQueue>
  ) -> Effect<Never, Never> {
    self.save(reports, to: reportsFileName, on: queue)
  }
}

let reportsFileName = "reports"
