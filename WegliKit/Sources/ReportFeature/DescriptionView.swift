// Created for weg-li in 2021.

import ComposableArchitecture
import DescriptionFeature
import Helper
import L10n
import LocationFeature
import ImagesFeature
import Styleguide
import SwiftUI

public struct DescriptionView: View {
  struct ViewState: Equatable {
    let description: DescriptionState
    let chargeType: String
    let brand: String
    let color: String
    let showEditScreen: Bool
    
    init(state: ReportState) {
      self.description = state.description
      self.brand = state.description.selectedBrand?.title ?? ""
      self.color = DescriptionState.colors[state.description.selectedColor].value
      self.chargeType = state.description.selectedCharge?.text ?? ""
      self.showEditScreen = state.showEditDescription
    }
  }
  
  let store: Store<ReportState, ReportAction>
  @ObservedObject private var viewStore: ViewStore<ViewState, ReportAction>
  
  public init(store: Store<ReportState, ReportAction>) {
    self.store = store
    viewStore = ViewStore(store.scope(state: ViewState.init))
  }
  
  public var body: some View {
    VStack(alignment: .leading) {
      VStack(alignment: .leading, spacing: 12) {
        row(title: L10n.Description.Row.licenseplateNumber, content: viewStore.description.licensePlateNumber)
        row(title: L10n.Description.Row.carType, content: viewStore.brand)
        row(title: L10n.Description.Row.carColor, content: viewStore.color)
        row(title: L10n.Description.Row.chargeType, content: viewStore.chargeType)
        row(title: L10n.Description.Row.length, content: viewStore.description.time)
        if viewStore.description.blockedOthers {
          HStack {
            Text(L10n.Description.Row.didBlockOthers)
              .foregroundColor(Color(.secondaryLabel))
              .font(.callout)
              .fontWeight(.bold)
            Spacer()
            Image(systemName: "checkmark.circle.fill")
              .foregroundColor(.primary)
          }
        }
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
        send: ReportAction.setShowEditDescription
      ), content: {
        EditDescriptionView(
          store: store.scope(
            state: \.description,
            action: ReportAction.description
          )
        )
        .accessibilityAddTraits([.isModal])
      }
    )
  }
  
  private func row(title: String, content: String) -> some View {
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

struct DescriptionWidgetView_Previews: PreviewProvider {
  static var previews: some View {
    Preview {
      Widget(
        title: Text("Beschreibung"),
        isCompleted: true
      ) {
        DescriptionView(
          store: .init(
            initialState: ReportState(
              uuid: UUID.init,
              images: ImagesViewState(),
              contactState: .preview,
              date: Date.init
            ),
            reducer: .empty,
            environment: ()
          )
        )
      }
    }
  }
}
