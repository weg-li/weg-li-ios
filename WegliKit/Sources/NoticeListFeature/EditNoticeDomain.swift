import ComposableArchitecture
import Foundation
import DescriptionFeature
import ImagesFeature
import SharedModels

public struct EditNoticeDomain: Reducer {
  public init() {}
  
  @Dependency(\.apiService) public var apiService
  
  public struct State: Equatable {
    var notice: Notice
    
    public var description: DescriptionDomain.State
    public var image: ImagesViewDomain.State
    
    @BindingState public var date: Date
    @BindingState public var licensePlateNumber: String
    @BindingState public var street: String
    @BindingState public var city: String
    @BindingState public var zip: String
    @BindingState public var presentChargeSelection = false
    @BindingState public var presentCarBrandSelection = false
    
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
    
    case onDeleteNoticeButtonTapped
    case deleteConfirmButtonTapped
    case deleteNoticeResponse(TaskResult<Bool>)
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
        
      case .onDeleteNoticeButtonTapped:
        state.alert = .confirmDeleteNotice
        return .none
        
      case .deleteConfirmButtonTapped:
        guard let token = state.notice.token else {
          return .none
        }
        state.isDeletingNotice = true
        
        return .task {
          await .deleteNoticeResponse(
            TaskResult { try await apiService.deleteNotice(token) }
          )
        }
        
      case .deleteNoticeResponse(let response):
        state.isDeletingNotice = false
        
        switch response {
        case .success:
          return .none
        case .failure(let error):
          debugPrint(error.localizedDescription)
          state.alert = .editNoticeFailure
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
