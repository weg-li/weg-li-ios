
// Created for weg-li in 2021.
import ApiClient
import ComposableArchitecture
import ComposableCoreLocation
import ContactFeature
import DescriptionFeature
import FeedbackGeneratorClient
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
import XCTestDynamicOverlay

public struct ReportDomain: Reducer {
  public init() {}
  
  @Dependency(\.continuousClock) public var clock
  @Dependency(\.locationManager) public var locationManager
  @Dependency(\.placesServiceClient) public var placeService
  @Dependency(\.regulatoryOfficeMapper) public var regulatoryOfficeMapper
  @Dependency(\.fileClient) public var fileClient
  @Dependency(\.pathMonitorClient) public var pathMonitorClient
  @Dependency(\.imagesUploadClient) public var imagesUploadClient
  @Dependency(\.apiService) public var wegliService
  @Dependency(\.applicationClient) public var uiApplicationClient
  @Dependency(\.date) public var date
  @Dependency(\.mailComposeClient) public var mailComposeClient
  @Dependency(\.feedbackGenerator) public var feedbackGenerator
  
  let postalCodeMinumimCharacters = 5
  
  public struct State: Equatable {
    public var id: String
    public var images: ImagesViewDomain.State
    public var contactState: ContactViewDomain.State
    public var district: District?
    
    @BindingState public var date: Date
    public var description: DescriptionDomain.State
    public var location: LocationDomain.State
    public var mail: MailDomain.State
    
    public var alert: AlertState<Action>?
    
    @BindingState public var showEditDescription = false
    @BindingState public var showEditContact = false
    
    public var apiToken = ""
    public var alwaysSendNotice = true
    
    public var uploadedImagesIds: [String] = []
    public var uploadProgressState: String?
    
    public var isPhotosValid: Bool { !images.storedPhotos.isEmpty }
    public var isContactValid: Bool { contactState.contact.isValid }
    public var isDescriptionValid: Bool { description.isValid }
    public var isLocationValid: Bool { location.resolvedAddress.isValid }
    public var isResetButtonDisabled: Bool {
      location.resolvedAddress == .init()
      && images.storedPhotos.isEmpty
      && description == .init()
    }
    
    public var isNetworkAvailable = true
    public var canSubmitNotice: Bool { isReportValid }
    public var isSubmittingNotice = false
    
    public var uploadedNoticeID: String?
    
    public var destination: Destination?
    
    public func isModified() -> Bool {
      district != nil
      || isPhotosValid
      || contactState.contact.isValid
      || location != .init()
      || description != .init()
    }
    
    public var isReportValid: Bool {
      var values = [
        images.isValid,
        location.resolvedAddress.isValid,
        description.isValid
      ]
      if apiToken.isEmpty {
        values.append(contactState.contact.isValid)
      }
      let isValid = values.allSatisfy { $0 == true }
      return isValid
    }
    
    init(
      id: String,
      images: ImagesViewDomain.State,
      contactState: ContactViewDomain.State,
      district: District? = nil,
      date: Date,
      description: DescriptionDomain.State,
      location: LocationDomain.State,
      mail: MailDomain.State,
      alert: AlertState<Action>? = nil,
      showEditDescription: Bool = false,
      showEditContact: Bool = false,
      apiToken: String = "",
      uploadedImagesIds: [String] = [],
      isNetworkAvailable: Bool = true
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
      self.isNetworkAvailable = isNetworkAvailable
    }
    
    public enum Destination: Equatable {
      case description
      case contact
    }
  }
  
  public enum Action: BindableAction, Equatable {
    case binding(BindingAction<State>)
    case onAppear
    case images(ImagesViewDomain.Action)
    case contact(ContactViewDomain.Action)
    case description(DescriptionDomain.Action)
    case location(LocationDomain.Action)
    case mail(MailDomain.Action)
    case mapAddressToDistrict(Address)
    case mapDistrictFinished(TaskResult<District>)
    
    case onResetButtonTapped
    case onSubmitButtonTapped
    case onResetConfirmButtonTapped
    
    case dismissAlert
    case uploadImages
    case uploadImagesResponse(TaskResult<[ImageUploadResponse]>)
    case composeNotice
    case postNoticeResponse(TaskResult<Notice>)
    case submitNoticeResponse(TaskResult<Notice>)
    case editNoticeInBrowser
    case setDestination(State.Destination?)
  }
  
  public var body: some ReducerOf<Self> {
    Scope(state: \.images, action: /Action.images) {
      ImagesViewDomain()
    }
    
    Scope(state: \.description, action: /Action.description) {
      DescriptionDomain()
    }
    
    Scope(state: \.contactState, action: /Action.contact) {
      ContactViewDomain()
    }
    
    Scope(state: \.location, action: /Action.location) {
      LocationDomain()
    }
    
    Scope(state: \.mail, action: /Action.mail) {
      MailDomain()
    }
    
    BindingReducer()
    
    Reduce<State, Action> { state, action in
      switch action {
      case .binding:
        return .none
        
      case .onAppear:
        return .none
        
        // Triggers district mapping after geoAddress is stored.
      case let .mapAddressToDistrict(input):
        return .task {
          await .mapDistrictFinished(
            TaskResult {
              try await regulatoryOfficeMapper.mapAddressToDistrict(input)
            }
          )
        }
        
      case let .mapDistrictFinished(.success(district)):
        state.district = district
        return .none
        
      case let .mapDistrictFinished(.failure(error)):
        // face error to user?
        debugPrint(error)
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
          
          return EffectTask(value: Action.location(.resolveLocation(coordinate)))
          
        case .setPhotos:
          if state.images.pickerResultCoordinate == nil {
            if let coordinate = state.location.region?.center {
              return EffectTask(value: .images(.setImageCoordinate(coordinate.asCLLocationCoordinate2D)))
            }
          }
          
          return .none
          
        case let .setImageCreationDate(date):
          // set report date from selected photos
          state.date = date ?? self.date.now
          return .none
          
          // Handle single image remove action to reset map annotations and reset valid state.
        case .image(_, .onRemovePhotoButtonTapped):
          if state.images.storedPhotos.isEmpty, state.location.locationOption == .fromPhotos {
            state.images.pickerResultCoordinate = nil
            state.location.pinCoordinate = nil
            state.location.resolvedAddress = .init()
            state.date = date.callAsFunction()
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
          return EffectTask(value: .mapAddressToDistrict(address))
          
        case let .resolveAddressFinished(.failure(error)):
          state.alert = .addressResolveFailed(error: error as! PlacesServiceError)
          return .none
          
          // Handle manual address entering to trigger district mapping.
        case let .updateGeoAddressPostalCode(postalCode):
          guard postalCode.count == postalCodeMinumimCharacters, postalCode.isNumeric else {
            return .none
          }
          return EffectTask(value: .mapAddressToDistrict(state.location.resolvedAddress))
          
        case .updateGeoAddressCity:
          return EffectTask(value: .mapAddressToDistrict(state.location.resolvedAddress))
          
        case let .setLocationOption(option) where option == .fromPhotos:
          if !state.images.storedPhotos.isEmpty, let coordinate = state.images.pickerResultCoordinate {
            return EffectTask(value: .location(.resolveLocation(coordinate)))
          } else {
            return .none
          }
          
        case let .setPinCoordinate(coordinate):
          guard let coordinate = coordinate, state.location.locationOption == .currentLocation else { return .none }
          return EffectTask(value: .location(.resolveLocation(coordinate)))
          
        default:
          return .none
        }
        
        // Compose mail when send mail button was tapped.
      case .mail(.submitButtonTapped):
        guard mailComposeClient.canSendMail() else {
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
        return EffectTask(value: .mail(.presentMailContentView(true)))
        
      case .mail:
        return .none
        
      case .contact:
        let contact = state.contactState.contact
        
        return .fireAndForget {
          enum CancelID {}
          try await withTaskCancellation(id: CancelID.self, cancelInFlight: true) {
            try await clock.sleep(for: .seconds(0.3))
            try await fileClient.saveContactSettings(contact)
          }
        }
        
      case .description:
        return .none
        
      case .onResetButtonTapped:
        state.alert = .resetReportAlert
        return .none
        
      case .onResetConfirmButtonTapped:
        // Reset report will be handled in the homeReducer
        return EffectTask(value: .dismissAlert)
        
      case .dismissAlert:
        state.alert = nil
        return .none
        
      case .onSubmitButtonTapped:
        guard state.isNetworkAvailable else {
          state.alert = .init(
            title: .init("Keine Internetverbindung"),
            message: .init("Verbinde dich mit dem Internet um die Meldung zu versenden"),
            buttons: [
              .cancel(.init(L10n.cancel)),
              .default(.init("Wiederholen"), action: .send(.onSubmitButtonTapped))
            ]
          )
          return .none
        }
        
        state.isSubmittingNotice = true
        return EffectTask(value: .uploadImages)
        
      case .uploadImages:
        let results = state.images.imageStates.map { $0.image }
        
        return .task {
          await .uploadImagesResponse(
            TaskResult {
              try await imagesUploadClient.uploadImages(results)
            }
          )
        }
        
      case let .uploadImagesResponse(.success(imageInputFromUpload)):
        state.uploadedImagesIds = imageInputFromUpload.map(\.signedId)
        return EffectTask(value: .composeNotice)
        
      case let .uploadImagesResponse(.failure(error)):
        state.isSubmittingNotice = false
        return EffectTask(value: .postNoticeResponse(.failure(ApiError(error: error))))
        
      case .composeNotice:
        var notice = NoticeInput(state)
        notice.photos = state.uploadedImagesIds
        
        return .task { [notice, alwaysSendNotice = state.alwaysSendNotice] in
          if alwaysSendNotice {
            return await .submitNoticeResponse(
              TaskResult {
                try await wegliService.submitNotice(notice)
              }
            )
          } else {
            return await .postNoticeResponse(
              TaskResult {
                try await wegliService.postNotice(notice)
              }
            )
          }
        }
        
      case let .postNoticeResponse(.success(response)):
        state.isSubmittingNotice = false
        state.uploadedNoticeID = response.token
        
        let imageURLs = state.images.storedPhotos.compactMap { $0?.imageUrl }
        return .fireAndForget {
          await withTaskGroup(of: Void.self, body: { group in
            imageURLs.forEach { url in
              group.addTask(priority: .background) {
                try? await fileClient.removeItem(url)
              }
            }
            debugPrint("removed items")
          })
        }
        
      case let .postNoticeResponse(.failure(error)):
        state.isSubmittingNotice = false
        if let apiError = error as? ApiError {
          state.alert = .sendNoticeFailed(error: apiError)
        }
        state.uploadProgressState = nil
        return .none
        
      case .editNoticeInBrowser:
        guard let id = state.uploadedNoticeID else {
          return .none
        }
        let editURL = URL(string: "https://www.weg.li/notices/\(id)/edit")!
        return .fireAndForget {
          _ = await uiApplicationClient.open(editURL, [:])
        }
        
      case .submitNoticeResponse(.success):
        state.isSubmittingNotice = false
        state.uploadedImagesIds.removeAll()
        
        state.alert = .reportSent
        
        let imageURLs = state.images.storedPhotos.compactMap { $0?.imageUrl }
        
        return .merge(
          .fireAndForget {
            await withTaskGroup(of: Void.self, body: { group in
              imageURLs.forEach { url in
                group.addTask(priority: .background) {
                  try? await fileClient.removeItem(url)
                }
              }
              debugPrint("removed items")
            })
          },
          .fireAndForget {
            await feedbackGenerator.notify(.success)
          }
        )
        
      case let .submitNoticeResponse(.failure(error)):
        state.isSubmittingNotice = false
        
        state.alert = .sendNoticeFailed(error: error as! ApiError)
        return .fireAndForget {
          await feedbackGenerator.notify(.error)
        }
      
      case .setDestination(let value):
        switch value {
        case .none:
          state.description.presentChargeSelection = false
          state.description.presentCarBrandSelection = false
        case .some:
          break
        }
        state.destination = value
        return .none
        
      }
    }
  }
}

public extension ReportDomain.State {
  init(
    uuid: @escaping () -> UUID,
    images: ImagesViewDomain.State = .init(),
    contactState: ContactViewDomain.State = .empty,
    district: District? = nil,
    date: () -> Date,
    description: DescriptionDomain.State = .init(),
    location: LocationDomain.State = .init(),
    mail: MailDomain.State = .init()
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


struct ObserveConnectionIdentifier: Hashable {}

// MARK: - Helper

public extension ReportDomain.State {
  static let preview = Self(
    uuid: UUID.init,
    images: .init(
      showImagePicker: false,
      storedPhotos: [PickerImageResult(uiImage: UIImage(systemName: "swift")!)!] // swiftlint:disable:this force_unwrapping
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
      licensePlateNumber: "XX-XX-123",
      selectedColor: 3,
      selectedBrand: .init("Opel"),
      selectedDuration: 5,
      selectedCharge: .init(id: "1", text: "Parken auf dem Radweg", isFavorite: true, isSelected: false),
      blockedOthers: true
    )
  )
}

public extension AlertState where Action == ReportDomain.Action {
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
      action: .send(.onResetConfirmButtonTapped)
    ),
    secondaryButton: .cancel(
      .init(L10n.cancel),
      action: .send(.dismissAlert)
    )
  )
  
  static let reportSent = Self(
    title: .init("Meldung gesendet"),
    message: .init("Deine Meldung wurde an die Behörden gesendet."),
    buttons: [
      .default(.init("Ok"), action: .send(.onResetConfirmButtonTapped)),
      .default(.init("Gehe zu `weg.li`"), action: .send(.editNoticeInBrowser))
    ]
  )
  
  static func sendNoticeFailed(error: ApiError) -> Self {
    Self(
      title: .init("Meldung konnte nicht gesendet werden"),
      message: .init("Fehler: \(error.message)"),
      buttons: [
        .default(.init(verbatim: "Erneut senden"), action: .send(.composeNotice)),
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

public extension SharedModels.NoticeInput {
  init(_ reportState: ReportDomain.State) {
    self.init(
      token: reportState.id,
      status: "open",
      street: reportState.location.resolvedAddress.street,
      city: reportState.location.resolvedAddress.city,
      zip: reportState.location.resolvedAddress.postalCode,
      latitude: reportState.location.pinCoordinate?.latitude ?? 0,
      longitude: reportState.location.pinCoordinate?.longitude ?? 0,
      registration: reportState.description.licensePlateNumber,
      brand: reportState.description.carBrandSelection.selectedBrand?.title ?? "",
      color: DescriptionDomain.colors[reportState.description.selectedColor].key,
      charge: reportState.description.chargeSelection.selectedCharge?.text ?? "",
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
  init(_ reportState: ReportDomain.State) {
    self.init(
      token: reportState.id,
      status: .open,
      street: reportState.location.resolvedAddress.street,
      city: reportState.location.resolvedAddress.city,
      zip: reportState.location.resolvedAddress.postalCode,
      latitude: reportState.location.pinCoordinate?.latitude ?? 0,
      longitude: reportState.location.pinCoordinate?.longitude ?? 0,
      registration: reportState.description.licensePlateNumber,
      brand: reportState.description.carBrandSelection.selectedBrand?.title ?? "",
      color: DescriptionDomain.colors[reportState.description.selectedColor].key,
      charge: reportState.description.chargeSelection.selectedCharge?.text ?? "",
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

extension ReportDomain.State {
  public init(_ model: SharedModels.Notice) {
    self.id = model.id
    self.images = .init(
      alert: nil,
      showCamera: false,
      showImagePicker: false,
      storedPhotos: model.photos?.compactMap { noticePhoto in
        PickerImageResult(
          id: UUID().uuidString,
          imageUrl: URL(string: noticePhoto.url)
        )
      } ?? [],
      coordinateFromImagePicker: nil,
      dateFromImagePicker: model.date
    )
    self.contactState = .empty
    self.district = nil
    self.date = model.createdAt ?? Date()
    self.description = .init(model: model)
    self.location = .init(
      locationOption: .manual,
      isMapExpanded: false,
      isResolvingAddress: false,
      resolvedAddress: .init(
        street: model.street ?? "",
        postalCode: model.zip ?? "",
        city: model.city ?? ""
      ),
      pinCoordinate: nil,
      isRequestingCurrentLocation: false,
      region: nil
    )
    self.mail = .init()
    self.alert = nil
    self.showEditDescription = false
    self.showEditContact = false
    self.apiToken = ""
    self.uploadedImagesIds = []
    self.isNetworkAvailable = false
  }
}


// MARK: - MailComposeClient Dependency

extension DependencyValues {
  public var mailComposeClient: MailComposeClient {
    get { self[MailComposeClient.self] }
    set { self[MailComposeClient.self] = newValue }
  }
}

public struct MailComposeClient {
  public var canSendMail: () -> Bool
}

extension MailComposeClient {
  static let live = Self(canSendMail: MFMailComposeViewController.canSendMail)
}

extension MailComposeClient: DependencyKey {
  public static let liveValue = Self { MFMailComposeViewController.canSendMail() }
  public static let testValue = Self(canSendMail: unimplemented())
}
