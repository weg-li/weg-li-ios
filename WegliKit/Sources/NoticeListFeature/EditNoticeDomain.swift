import ApiClient
import ComposableArchitecture
import DescriptionFeature
import FeedbackGeneratorClient
import Foundation
import L10n
import ImagesFeature
import SharedModels

public struct EditNoticeDomain: Reducer {
  public init() {}
  
  @Dependency(\.apiService) public var apiService
  @Dependency(\.feedbackGenerator) public var feedbackGenerator
  @Dependency(\.dismiss) var dismiss
  
  public struct State: Equatable, Identifiable {
    @BindingState public var notice: Notice
    
    public var id: String { notice.id }
    
    @BindingState public var description: DescriptionDomain.State
    public var image: ImagesViewDomain.State
    
    @BindingState public var date: Date
    @BindingState public var licensePlateNumber: String
    @BindingState public var street: String
    @BindingState public var city: String
    @BindingState public var zip: String
    @BindingState public var presentChargeSelection = false
    @BindingState public var presentCarBrandSelection = false
    @BindingState public var isSendingNoticeUpdate = false
    @BindingState public var showImagePicker = false
    public var destination: Destination?
    
    public enum Destination: Equatable {
      case selectBrand(CarBrandSelection.State)
    }
    
    public var isDeletingNotice = false
    public var alert: AlertState<Action>?
    
    init(notice: Notice) {
      self.notice = notice
      self.description = .init(model: notice)
      let photos: [PickerImageResult] = notice.photos?.compactMap { photo in
        PickerImageResult(id: photo.filename, imageUrl: URL(string: photo.url))
      } ?? []
      self.image = .init(storedPhotos: photos)
      self.licensePlateNumber = notice.registration ?? ""
      self.date = notice.date ?? .now
      self.street = notice.street ?? ""
      self.city = notice.city ?? ""
      self.zip = notice.zip ?? ""
    }
  }
  
  public enum Action: Equatable, BindableAction {
    case binding(BindingAction<State>)
    case description(DescriptionDomain.Action)
    case setDestination(State.Destination?)
    case image(ImagesViewDomain.Action)
    
    case closeButtonTapped
    case saveButtonTapped
    case deleteNoticeButtonTapped
    case deleteConfirmButtonTapped
    case deleteNoticeResponse(TaskResult<Bool>)
    case editNoticeResponse(TaskResult<Notice>)
    case dismissAlert
  }
  
  public var body: some ReducerOf<Self> {
    Scope(state: \.description, action: /Action.description) {
      DescriptionDomain()
    }
    
    Scope(state: \.image, action: /Action.image) {
      ImagesViewDomain()
    }
    
    BindingReducer()
    
    Reduce<State, Action> { state, action in
      switch action {
      case .binding:
        return .none
        
      case .description(.chargeSelection(.setCharge)):
        state.description.presentChargeSelection = false
        return .none
      case .description(.carBrandSelection(.setBrand)):
        state.presentCarBrandSelection = false
        return .none
        
      case .description, .setDestination:
        return .none
        
      case .closeButtonTapped:
        return .run { _ in
          await dismiss()
        }
      
      case .deleteNoticeButtonTapped:
        state.alert = .confirmDeleteNotice
        return .none
        
      case .deleteConfirmButtonTapped:
        guard let token = state.notice.token else {
          return .none
        }
        state.isDeletingNotice = true
        
        return .run { send in
          await send(
            .deleteNoticeResponse(
              TaskResult { try await apiService.deleteNotice(token) }
            )
          )
        }
        
      case .saveButtonTapped:
        state.isSendingNoticeUpdate = true

        return .run { [patch = state.asNoticePatch()] send in
          await send(
            .editNoticeResponse(
              TaskResult { try await apiService.patchNotice(patch) }
            )
          )
        }
        
      case .editNoticeResponse(let response):
        state.isSendingNoticeUpdate = false
        
        switch response {
        case .success:
          return .run { send in
            await feedbackGenerator.notify(.success)
          }
          
        case .failure(let error):
          state.alert = .editNoticeFailure(message: error.localizedDescription)
          return .run { _ in
            await feedbackGenerator.notify(.error)
          }
        }
          
      case .deleteNoticeResponse(let response):
        state.isDeletingNotice = false
        
        switch response {
        case .success:
          return .none
        case .failure(let error):
          state.alert = .deleteNoticeFailure(message: error.localizedDescription)
          return .none
        }
        
      case .dismissAlert:
        state.alert = nil
        return .none
        
      case .image:
        return .none
      }
    }
  }
}

extension EditNoticeDomain.State {
  func asNoticePatch() -> Notice {
    let charge = description.chargeSelection.selectedCharge.flatMap {
      DescriptionDomain.noticeCharge(with: $0.id) } ?? .init(tbnr: "")
    
    return Notice(
      token: notice.token ?? "",
      status: notice.status ?? .open,
      street: street,
      city: city,
      zip: zip,
      latitude: notice.latitude ?? 0,
      longitude: notice.longitude ?? 0,
      registration: licensePlateNumber,
      brand: description.carBrandSelection.selectedBrand?.title ?? "",
      color: DescriptionDomain.colors[description.selectedColor].key,
      tbnr: charge.tbnr,
      charge: charge,
      date: date,
      duration: Int64(description.selectedDuration),
      severity: notice.severity,
      note: notice.note ?? "",
      createdAt: notice.createdAt ?? Date(),
      updatedAt: Date(),
      sentAt: Date(),
      vehicleEmpty: description.vehicleEmpty,
      hazardLights: description.hazardLights,
      expiredTuv: description.expiredTuv,
      expiredEco: description.expiredEco,
      over28Tons: description.over28Tons,
      photos: notice.photos ?? []
    )
  }
}

public extension AlertState where Action == EditNoticeDomain.Action {
  static func editNoticeFailure(message: String? = nil) -> Self {
    Self(
      title: .init("Fehler"),
      message: .init(message ?? "Die Meldung konnte nicht gelöscht werden"),
      buttons: [
        .default(.init("Ok")),
        .default(.init("Wiederholen"), action: .send(.saveButtonTapped))
      ]
    )
  }
  
  static func deleteNoticeFailure(message: String? = nil) -> Self {
    Self(
      title: .init("Fehler"),
      message: .init(message ?? "Die Meldung konnte nicht gelöscht werden"),
      buttons: [
        .default(.init("Ok")),
        .default(.init("Wiederholen"), action: .send(.deleteConfirmButtonTapped))
      ]
    )
  }
  
  static let confirmDeleteNotice = Self(
    title: .init("Meldung löschen"),
    buttons: [
      .default(.init(L10n.cancel)),
      .destructive(.init("Löschen"), action: .send(.deleteConfirmButtonTapped)),
    ]
  )
}
