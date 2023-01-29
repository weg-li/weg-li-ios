import ComposableArchitecture
import DescriptionFeature
import Helper
import ImagesFeature
import L10n
import LocationFeature
import ReportFeature
import SharedModels
import Styleguide
import SwiftUI

public struct EditNoticeDomain: ReducerProtocol {
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
  
  public var body: some ReducerProtocol<State, Action> {
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


struct EditNoticeView: View {
  public typealias S = EditNoticeDomain.State
  public typealias A = EditNoticeDomain.Action
  
  private let store: Store<S, A>
  @ObservedObject private var viewStore: ViewStore<S, A>
  
  public init(store: Store<S, A>) {
    self.store = store
    self.viewStore = ViewStore(store)
  }
  
  var body: some View {
    ScrollView {
      VStack(alignment: .leading) {
        Widget(title: Text(L10n.Photos.widgetTitle), shouldIndicateCompletion: false) {
          VStack {
            ImageGridView(
              store: store.scope(
                state: \.image,
                action: EditNoticeDomain.Action.image
              )
            )
            
            Button(
              action: { viewStore.send(.image(.onAddPhotosButtonTapped)) },
              label: {
                Label(L10n.Photos.ImportButton.copy, systemImage: "photo.on.rectangle.angled")
                  .frame(maxWidth: .infinity)
              }
            )
            .buttonStyle(.edit())
          }
          .sheet(
            isPresented: viewStore.binding(\.image.$showImagePicker),
            content: {
              ImagePicker(
                isPresented: viewStore.binding(\.image.$showImagePicker),
                pickerResult: viewStore.binding(
                  get: \.image.storedPhotos,
                  send: { EditNoticeDomain.Action.image(.setPhotos($0)) }
                )
              )
            }
          )
        }
        .padding(.vertical, .grid(2))
        
        Widget(title: Text( L10n.Location.widgetTitle), shouldIndicateCompletion: false) {
          VStack(alignment: .leading) {
            TextField(
              L10n.Location.Placeholder.street,
              text: viewStore.binding(\.$street)
            )
            TextField(
              L10n.Location.Placeholder.city,
              text: viewStore.binding(\.$city)
            )
            TextField(
              L10n.Location.Placeholder.postalCode,
              text: viewStore.binding(\.$zip)
            )
          }
        }
        .padding(.vertical, .grid(1))
        
        Widget(title: Text( L10n.date), shouldIndicateCompletion: false) {
          HStack {
            DatePicker(
              L10n.date,
              selection: viewStore.binding(\.$date)
            )
            .labelsHidden()
            Spacer()
          }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, .grid(2))
        
        Widget(title: Text(L10n.Description.widgetTitle), shouldIndicateCompletion: false) {
          VStack(spacing: .grid(2)) {
            licensePlateView
              .padding(.bottom)
            carBrandView
              .padding(.bottom)
            carColorView
              .padding(.bottom)
            chargeTypeView
              .padding(.bottom)
            chargeDurationView
              .padding(.bottom)
            blockedOthersView
            vehicleEmptyView
            hazardLightsView
            expiredTuvView
            expiredEcoView
          }
          .foregroundColor(Color(uiColor: .label))
        }
        
        VStack(alignment: .leading) {
          if let createdAtDate = viewStore.notice.createdAt {
            HStack {
              Text("Erstellt am: ")
              Text(createdAtDate.humandReadableDate)
              Spacer()
            }
          }
          if let sentAtDate = viewStore.notice.sentAt {
            HStack {
              Text("Gesendet am: ")
              Text(sentAtDate.humandReadableDate)
              Spacer()
            }
          }
        }
        .padding()
        .font(.subheadline)
        
        Divider()
          .padding(.vertical, .grid(8))
        
        Button(
          action: { viewStore.send(.onDeleteNoticeButtonTapped) },
          label: {
            if viewStore.isDeletingNotice {
              ProgressView()
                .tint(.white)
            } else {
              Label("Meldung löschen", systemImage: "trash")
                .font(.body)
                .fontWeight(.semibold)
            }
          }
        )
        .frame(maxWidth: .infinity)
        .padding()
        .foregroundColor(.white)
        .background(Color.red)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding()
      }
    }
    .alert(store.scope(state: \.alert), dismiss: .dismissAlert)
    .textFieldStyle(.roundedBorder)
  }
  
  var licensePlateView: some View {
    TextField(
      L10n.Description.Row.licenseplateNumber,
      text: viewStore.binding(\.description.$licensePlateNumber)
    )
    .textFieldStyle(.roundedBorder)
    .disableAutocorrection(true)
    .textInputAutocapitalization(.characters)
  }
  
  var carBrandView: some View {
    NavigationLink(
      isActive: viewStore.binding(\.$presentCarBrandSelection),
      destination: {
        CarBrandSelectorView(
          store: self.store.scope(
            state: \.description.carBrandSelection,
            action: { A.description(.carBrandSelection($0)) }
          )
        )
        .navigationTitle(Text(L10n.Description.Row.carType))
        .navigationBarTitleDisplayMode(.inline)
      },
      label: {
        HStack {
          Text(L10n.Description.Row.carType)
          Spacer()
          if let brand = viewStore.description.carBrandSelection.selectedBrand {
            Text(brand.title)
              .fontWeight(.bold)
          }
          Image(systemName: "chevron.forward")
        }
        .contentShape(Rectangle())
        .onTapGesture {
          viewStore.send(.set(\.$presentCarBrandSelection, true))
        }
      }
    )
  }
  
  var carColorView: some View {
    HStack {
      Text(L10n.Description.Row.carColor)
      Spacer()
      Picker(
        L10n.Description.Row.carColor,
        selection: viewStore.binding(\.description.$selectedColor)
      ) {
        ForEach(1 ..< DescriptionDomain.colors.count, id: \.self) {
          Text(DescriptionDomain.colors[$0].value)
            .contentShape(Rectangle())
            .tag($0)
            .foregroundColor(Color(.label))
        }
      }
    }
  }
  
  var chargeTypeView: some View {
    NavigationLink(
      isActive: viewStore.binding(\.$presentChargeSelection),
      destination: {
        ChargeSelectionView(
          store: self.store.scope(
            state: \.description.chargeSelection,
            action: { A.description(.chargeSelection($0)) }
          )
        )
        .accessibilityAddTraits([.isModal])
        .navigationTitle(Text(L10n.Description.Row.chargeType))
        .navigationBarTitleDisplayMode(.inline)
      },
      label: {
        HStack {
          Text(L10n.Description.Row.chargeType)
          Spacer()
          if let charge = viewStore.description.chargeSelection.selectedCharge {
            Text(charge.text)
              .fontWeight(.bold)
          }
          Image(systemName: "chevron.forward")
        }
        .contentShape(Rectangle())
        .onTapGesture {
          viewStore.send(.set(\.$presentChargeSelection, true))
        }
      }
    )
  }
  
  var times: [Int] {
    Array(
      Times.times.sorted(by: { $0.0 < $1.0 })
        .map(\.key)
        .dropFirst()
    )
  }
  var chargeDurationView: some View {
    HStack {
      Text("Dauer")
      Spacer()
      Picker(
        L10n.Description.Row.length,
        selection: viewStore.binding(\.description.$selectedDuration)
      ) {
        ForEach(times, id: \.self) { time in
          Text(Times.times[time] ?? "")
            .contentShape(Rectangle())
            .foregroundColor(Color(.label))
        }
      }
    }
  }
  
  var blockedOthersView: some View {
    ToggleButton(
      label: L10n.Description.Row.didBlockOthers,
      isOn: viewStore.binding(\.description.$blockedOthers)
    )
  }
  
  var vehicleEmptyView: some View {
    ToggleButton(
      label: "Das Fahrzeug war verlassen",
      isOn: viewStore.binding(\.description.$vehicleEmpty)
    )
  }
  
  var hazardLightsView: some View {
    ToggleButton(
      label: "Das Fahrzeug hatte die Warnblinkanlage aktiviert",
      isOn: viewStore.binding(\.description.$hazardLights)
    )
  }
  
  var expiredTuvView: some View {
    ToggleButton(
      label: "Die TÜV-Plakette war abgelaufen",
      isOn: viewStore.binding(\.description.$expiredTuv)
    )
  }
  
  var expiredEcoView: some View {
    ToggleButton(
      label: "Die Umwelt-Plakette fehlte oder war ungültig",
      isOn: viewStore.binding(\.description.$expiredEco)
    )
  }
}

struct SwiftUIView_Previews: PreviewProvider {
  static var previews: some View {
    EditNoticeView(
      store: .init(
        initialState: EditNoticeDomain.State(notice: .mock),
        reducer: EditNoticeDomain()
      )
    )
  }
}

public extension AlertState where Action == EditNoticeDomain.Action {
  static let editNoticeFailure = Self(
    title: .init("Fehler"),
    message: .init("Die Meldung konnte nicht gelöscht werden"),
    buttons: [
      .default(.init("Ok")),
      .default(.init("Wiederholen"), action: .send(.deleteConfirmButtonTapped))
    ]
  )
  
  static let confirmDeleteNotice = Self(
    title: .init("Meldung löschen"),
    buttons: [
      .destructive(.init("Löschen"), action: .send(.deleteConfirmButtonTapped)),
    ]
  )
}
