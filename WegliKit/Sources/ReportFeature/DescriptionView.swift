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
    
    init(state: Report) {
      self.description = state.description
      self.brand = DescriptionState.brands[state.description.selectedBrand]
      self.color = DescriptionState.colors[state.description.selectedColor].value
      self.chargeType = state.description.selectedCharge?.text ?? ""
      self.showEditScreen = state.showEditDescription
    }
  }
  
  let store: Store<Report, ReportAction>
  @ObservedObject private var viewStore: ViewStore<ViewState, ReportAction>
  
  public init(store: Store<Report, ReportAction>) {
    self.store = store
    viewStore = ViewStore(store.scope(state: ViewState.init))
  }
  
  public var body: some View {
    VStack(alignment: .leading) {
      VStack(alignment: .leading, spacing: 12) {
        row(title: L10n.Description.Row.carType, content: viewStore.brand)
        row(title: L10n.Description.Row.carColor, content: viewStore.color)
        row(title: L10n.Description.Row.licenseplateNumber, content: viewStore.description.licensePlateNumber)
        row(title: L10n.Description.Row.length, content: viewStore.description.time)
        row(title: L10n.Description.Row.chargeType, content: viewStore.chargeType)
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
      Button(
        action: { viewStore.send(.setShowEditDescription(true)) },
        label: {
          HStack {
            Image(systemName: "pencil")
            Text(L10n.Description.EditButton.copy)
          }
          .frame(maxWidth: .infinity)
        }
      )
        .buttonStyle(EditButtonStyle())
        .padding(.top)
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
      }
    )
  }
  
  private func row(title: String, content: String) -> some View {
    VStack(alignment: .leading, spacing: 4.0) {
      Text(title)
        .foregroundColor(.secondary)
        .font(.callout)
      Text(content)
        .foregroundColor(.primary)
        .font(.body)
    }
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
            initialState: Report(
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
