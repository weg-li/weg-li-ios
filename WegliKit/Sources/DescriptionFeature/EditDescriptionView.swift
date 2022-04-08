// Created for weg-li in 2021.

import ComposableArchitecture
import Helper
import L10n
import SharedModels
import Styleguide
import SwiftUI

public struct EditDescriptionView: View {
  @Environment(\.presentationMode) var presentationMode
  @Environment(\.isSearching) var isSearching
  
  let store: Store<DescriptionState, DescriptionAction>
  @ObservedObject private var viewStore: ViewStore<DescriptionState, DescriptionAction>
  
  public init(store: Store<DescriptionState, DescriptionAction>) {
    self.store = store
    viewStore = ViewStore(store)
  }
  
  public var body: some View {
    NavigationView {
      Form {
        Section(header: Text(L10n.Description.Section.Vehicle.copy)) {
          licensePlateView

          carBrandView

          carColorView
        }
        .padding(.top, 4)
        .textFieldStyle(PlainTextFieldStyle())
        
        Section(header: Text(L10n.Description.Section.Violation.copy)) {
          chargeTypeView

          chargeLengthView

          blockedOthersView
        }
      }
      .onAppear { viewStore.send(.onAppear) }
      .navigationTitle(Text(L10n.Description.widgetTitle))
      .navigationBarTitleDisplayMode(.inline)
      .navigationBarItems(leading: closeButton)
    }
  }
  
  var licensePlateView: some View {
    TextField(
      "\(L10n.Description.Row.licenseplateNumber) *",
      text: viewStore.binding(
        get: \.licensePlateNumber,
        send: DescriptionAction.setLicensePlateNumber
      )
    )
  }
  
  var carBrandView: some View {
    Picker(
      L10n.Description.Row.carType,
      selection: viewStore.binding(
        get: \.selectedBrand,
        send: DescriptionAction.setBrand
      )
    ) {
      ForEach(1..<DescriptionState.brands.count, id: \.self) {
        Text(DescriptionState.brands[$0])
          .tag($0)
          .foregroundColor(Color(.label))
      }
    }
  }
  
  var carColorView: some View {
    Picker(
      L10n.Description.Row.carColor,
      selection: viewStore.binding(
        get: \.selectedColor,
        send: DescriptionAction.setColor
      )
    ) {
      ForEach(1..<DescriptionState.colors.count, id: \.self) {
        Text(DescriptionState.colors[$0].value)
          .tag($0)
          .foregroundColor(Color(.label))
      }
    }
  }
  
  var chargeTypeView: some View {
    NavigationLink(
      destination: {
        List {
          ForEach(viewStore.searchResults, id: \.id) { charge in
            ChargeView(
              text: charge.text,
              isSelected: viewStore.selectedCharge == charge,
              isFavorite: charge.isFavorite
            )
              .onTapGesture {
                viewStore.send(.setCharge(charge))
              }
              .swipeActions {
                Button(
                  action: {
                    viewStore.send(.toggleChargeFavorite(charge))
                  },
                  label: {
                    Image(systemName: "star.fill")
                  }
                )
                  .tint(.yellow)
              }
          }
        }.searchable(
          text: viewStore.binding(
            get: \.chargeTypeSearchText,
            send: DescriptionAction.setChargeTypeSearchText
          ),
          placement: .navigationBarDrawer(displayMode: .always)
        )
      },
      label: {
        HStack {
          Text(L10n.Description.Row.chargeType)
          if let charge = viewStore.state.selectedCharge {
            Spacer()
            Text(charge.text)
          }
        }
      }
    )
  }
  
  var chargeLengthView: some View {
    Picker(
      L10n.Description.Row.length,
      selection: viewStore.binding(
        get: \.selectedDuration,
        send: DescriptionAction.setDuraration
      )
    ) {
      ForEach(1..<Times.allCases.count, id: \.self) {
        Text(Times.allCases[$0].description)
          .foregroundColor(Color(.label))
      }
    }
  }
  
  var blockedOthersView: some View {
    Button(
      action: {
        viewStore.send(.toggleBlockedOthers)
      },
      label: {
        HStack {
          Text(L10n.Description.Row.didBlockOthers)
            .foregroundColor(.secondary)
          Spacer()
          ToggleButton(
            isOn: viewStore.binding(
              get: \.blockedOthers,
              send: DescriptionAction.toggleBlockedOthers
            )
          ).accessibleAnimation(.easeIn(duration: 0.2), value: viewStore.blockedOthers)
        }
      }
    )
  }
  
  var closeButton: some View {
    Button(
      action: { presentationMode.wrappedValue.dismiss() },
      label: { Text(L10n.Button.close) }
    )
  }
}

struct Description_Previews: PreviewProvider {
  static var previews: some View {
    Preview {
      EditDescriptionView(
        store: .init(
          initialState: .init(),
          reducer: .empty,
          environment: ()
        )
      )
    }
  }
}
