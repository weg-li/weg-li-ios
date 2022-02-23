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
import PlacesServiceClient
import RegulatoryOfficeMapper
import SharedModels
import SwiftUI

// MARK: - Report Core

public struct Report: Codable {
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
  
  public init(
    uuid: UUID = UUID(),
    images: ImagesViewState,
    contactState: ContactState,
    district: District? = nil,
    date: () -> Date = Date.init,
    description: DescriptionState = DescriptionState(),
    location: LocationViewState = LocationViewState(),
    mail: MailViewState = MailViewState()
  ) {
    id = uuid.uuidString
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

extension Report: Equatable {
  public static func == (lhs: Report, rhs: Report) -> Bool {
    lhs.contactState == rhs.contactState
    && lhs.district == rhs.district
    && lhs.description == rhs.description
    && lhs.location == rhs.location
  }
}

public enum ReportAction: Equatable {
  case images(ImagesViewAction)
  case contact(ContactAction)
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
}

public struct ReportEnvironment {
  public init(
    mainQueue: AnySchedulerOf<DispatchQueue>,
    mapAddressQueue: AnySchedulerOf<DispatchQueue> = mapperQueue.eraseToAnyScheduler(),
    locationManager: LocationManager,
    placeService: PlacesServiceClient,
    regulatoryOfficeMapper: RegulatoryOfficeMapper
  ) {
    self.mainQueue = mainQueue
    self.mapAddressQueue = mapAddressQueue
    self.locationManager = locationManager
    self.placeService = placeService
    self.regulatoryOfficeMapper = regulatoryOfficeMapper
  }
  
  public var mainQueue: AnySchedulerOf<DispatchQueue>
  public var mapAddressQueue: AnySchedulerOf<DispatchQueue>
  public var locationManager: LocationManager
  public var placeService: PlacesServiceClient
  public var regulatoryOfficeMapper: RegulatoryOfficeMapper
  
  let debounce = 0.5
  let postalCodeMinumimCharacters = 5
}

/// Combined reducer that is used in the ReportView and combing descending reducers.
public let reportReducer = Reducer<Report, ReportAction, ReportEnvironment>.combine(
  imagesReducer.pullback(
    state: \.images,
    action: /ReportAction.images,
    environment: {
      ImagesViewEnvironment(
        mainQueue: $0.mainQueue,
        photoLibraryAccessClient: .live()
      )
    }
  ),
  descriptionReducer.pullback(
    state: \.description,
    action: /ReportAction.description,
    environment: { _ in DescriptionEnvironment() }
  ),
  contactReducer.pullback(
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
      // Triggers district mapping after geoAddress is stored.
    case let .mapAddressToDistrict(input):
      return environment.regulatoryOfficeMapper
        .mapAddressToDistrict(input)
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
      case let .setResolvedCoordinate(coordinate):
        guard let coordinate = coordinate, coordinate != state.location.userLocationState.region?.center else {
          state.alert = .noPhotoCoordinate
          return .none
        }
        state.location.userLocationState.region = CoordinateRegion(center: coordinate)
        state.images.coordinateFromImagePicker = coordinate
        return Effect(value: ReportAction.location(.resolveLocation(coordinate)))
        
        // Handle single image remove action to reset map annotations and reset valid state.
      case .image:
        if state.images.storedPhotos.isEmpty, state.location.locationOption == .fromPhotos {
          state.images.coordinateFromImagePicker = nil
          state.location.resolvedAddress = .init()
        }
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
        if !state.images.storedPhotos.isEmpty, let coordinate = state.images.coordinateFromImagePicker {
          return Effect(value: .location(.resolveLocation(coordinate)))
        } else {
          return .none
        }
      default:
        return .none
      }
      
      // Compose mail when send mail button was tapped.
    case let .mail(mailAction):
      if MailViewAction.submitButtonTapped == mailAction {
        guard let district = state.district else {
          return .none
        }
        state.mail.mail.address = district.email
        state.mail.mail.body = state.createMailBody()
        state.mail.mail.attachmentData = state.images.storedPhotos
          .compactMap { $0?.imageUrl }
          .compactMap { try? Data(contentsOf: $0) }
        return Effect(value: ReportAction.mail(.presentMailContentView(true)))
      } else {
        return .none
      }
      
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
    }
  }
).debug()

public extension Report {
  static var preview: Report {
    Report(
      uuid: UUID(),
      images: .init(
        showImagePicker: false,
        storedPhotos: [StorableImage(uiImage: UIImage(systemName: "trash")!)!] // swiftlint:disable:this force_unwrapping
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
      date: Date.init,
      description: .init(
        licensePlateNumber: "HH-ST-PAULI",
        selectedColor: 0,
        selectedBrand: 0,
        selectedDuration: 0,
        selectedType: 0,
        blockedOthers: false
      ),
      location: LocationViewState()
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
  
  static let noPhotoCoordinate = Self(
    title: TextState(L10n.Location.Alert.noCoordinate)
  )
}

public let mapperQueue = DispatchQueue(
  label: "li.weg.iosclient.RegulatoryOfficeMapper",
  qos: .userInitiated,
  attributes: .concurrent
)
