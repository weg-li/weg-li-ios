// Created for weg-li in 2021.

import ComposableArchitecture
import DescriptionFeature
import Helper
import ImagesFeature
import L10n
import LocationFeature
import Styleguide
import SwiftUI

public struct DescriptionView: View {
  struct ViewState: Equatable {
    let description: DescriptionDomain.State
    let chargeType: String
    let brand: String
    let color: String
    let showEditScreen: Bool
    
    init(state: ReportDomain.State) {
      self.description = state.description
      self.brand = state.description.selectedBrand?.title ?? ""
      self.color = DescriptionDomain.State.colors[state.description.selectedColor].value
      self.chargeType = state.description.selectedCharge?.text ?? ""
      self.showEditScreen = state.showEditDescription
    }
  }
  
  let store: Store<ReportDomain.State, ReportDomain.Action>
  @ObservedObject private var viewStore: ViewStore<ViewState, ReportDomain.Action>
  
  public init(store: Store<ReportDomain.State, ReportDomain.Action>) {
    self.store = store
    self.viewStore = ViewStore(store.scope(state: ViewState.init))
  }
  
  public var body: some View {
    VStack(alignment: .leading) {
      VStack(alignment: .leading, spacing: 12) {
        row(title: L10n.Description.Row.licenseplateNumber, content: viewStore.description.licensePlateNumber)
        
        row(title: L10n.Description.Row.carType, content: viewStore.brand)
        
        row(title: L10n.Description.Row.carColor, content: viewStore.color)
        
        row(title: L10n.Description.Row.chargeType, content: viewStore.chargeType)
        
        row(title: L10n.Description.Row.length, content: viewStore.description.time)
        
        toggleRow(
          label: L10n.Description.Row.didBlockOthers,
          value: viewStore.description.blockedOthers
        )
        
        toggleRow(
          label: "Das Fahrzeug war verlassen",
          value: viewStore.description.vehicleEmpty
        )
        
        toggleRow(
          label: "Das Fahrzeug hatte die Warnblinkanlage aktiviert",
          value: viewStore.description.hazardLights
        )
        
        toggleRow(
          label: "Die TÜV-Plakette war abgelaufen",
          value: viewStore.description.expiredTuv
        )
        
        toggleRow(
          label: "Die Umwelt-Plakette fehlte oder war ungültig",
          value: viewStore.description.expiredEco
        )
      }
      .accessibilitySortPriority(1)
      .accessibilityElement(children: .combine)
      
      Button(
        action: { viewStore.send(.setShowEditDescription(true)) },
        label: {
          Label(L10n.Description.EditButton.copy, systemImage: "square.and.pencil")
            .contentShape(Rectangle())
            .frame(maxWidth: .infinity)
        }
      )
      .accessibilitySortPriority(2)
      .buttonStyle(EditButtonStyle())
      .padding(.top)
      .accessibilityAction {
        viewStore.send(.setShowEditDescription(true))
      }
    }
    .contentShape(Rectangle())
    .onTapGesture {
      viewStore.send(.setShowEditDescription(true))
    }
    .sheet(
      isPresented: viewStore.binding(
        get: \.showEditScreen,
        send: ReportDomain.Action.setShowEditDescription
      ), content: {
        EditDescriptionView(
          store: store.scope(
            state: \.description,
            action: ReportDomain.Action.description
          )
        )
        .accessibilityAddTraits([.isModal])
      }
    )
  }
  
  func toggleRow(label: String, value: Bool) -> some View {
    HStack {
      Text(label)
        .multilineTextAlignment(.leading)
        .foregroundColor(Color(.secondaryLabel))
        .font(.callout)
      Spacer()
      Image(systemName: value ? "checkmark.circle.fill" : "circle")
        .foregroundColor(.primary)
    }
  }
  
  func row(title: String, content: String) -> some View {
    VStack(alignment: .leading, spacing: .grid(1)) {
      Text(title)
        .foregroundColor(.secondary)
        .font(.callout)
      Text(content)
        .foregroundColor(.primary)
        .font(.body)
    }
    .accessibilityElement(children: .combine)
  }
}

//struct DescriptionWidgetView_Previews: PreviewProvider {
//  static var previews: some View {
//    Preview {
//      DescriptionView(
//        store: .init(
//          initialState: ReportDomain.State(uuid: UUID.init, date: Date.init),
//          reducer: DescriptionDomain()
//        )
//      )
//    }
//  }
//}
