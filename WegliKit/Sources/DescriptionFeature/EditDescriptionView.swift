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
        .padding(.top, .grid(1))
        .textFieldStyle(PlainTextFieldStyle())
        
        Section(header: Text(L10n.Description.Section.Violation.copy)) {
          chargeTypeView

          chargeDurationView

          blockedOthersView
          
          verhicleEmtpyView
          
          hazardLightsView
          
          expiredTuvView
          
          expiredEcoView
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
      L10n.Description.Row.licenseplateNumber,
      text: viewStore.binding(
        get: \.licensePlateNumber,
        send: DescriptionAction.setLicensePlateNumber
      )
    )
    .disableAutocorrection(true)
    .textInputAutocapitalization(.characters)
  }
  
  var carBrandView: some View {
    NavigationLink(
      isActive: viewStore.binding(
        get: \.presentCarBrandSelection,
        send: DescriptionAction.presentBrandSelectionView
      ),
      destination: {
        List {
          ForEach(viewStore.state.carBrandSearchResults, id: \.id) { brand in
            HStack {
              Text(brand.title)
                .foregroundColor(Color(.label))
                .multilineTextAlignment(.leading)
              Spacer()
              if viewStore.state.selectedBrand == brand {
                Image(systemName: "checkmark")
                  .resizable()
                  .frame(width: .grid(5), height: .grid(5))
                  .foregroundColor(.wegliBlue)
              }
            }
            .accessibilityValue(Text(viewStore.state.selectedBrand == brand ? "ausgewählt" : ""))
            .padding(.grid(1))
            .contentShape(Rectangle())
            .onTapGesture {
              viewStore.send(.setBrand(brand))
            }
          }
        }.searchable(
          text: viewStore.binding(
            get: \.carBrandSearchText,
            send: DescriptionAction.setCarBrandSearchText
          ),
          placement: .navigationBarDrawer(displayMode: .always)
        )
      },
      label: {
        HStack {
          Text(L10n.Description.Row.carType)
          if let brand = viewStore.state.selectedBrand {
            Spacer()
            Text(brand.title)
          }
        }
        .contentShape(Rectangle())
        .onTapGesture {
          viewStore.send(.presentBrandSelectionView(true))
        }
      }
    )
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
          .contentShape(Rectangle())
          .tag($0)
          .foregroundColor(Color(.label))
      }
    }
  }
  
  var chargeTypeView: some View {
    NavigationLink(
      isActive: viewStore.binding(
        get: \.presentChargeSelection,
        send: DescriptionAction.presentCargeSelectionView
      ),
      destination: {
        List {
          ForEach(viewStore.chargesSearchResults, id: \.id) { charge in
            ChargeView(
              text: charge.text,
              isSelected: viewStore.selectedCharge?.id == charge.id,
              isFavorite: charge.isFavorite,
              onTap: { viewStore.send(.setCharge(charge)) },
              onSwipe: { viewStore.send(.toggleChargeFavorite(charge)) }
            )
          }
        }
        .animation(.default, value: viewStore.chargesSearchResults)
        .searchable(
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
        .contentShape(Rectangle())
        .onTapGesture {
          viewStore.send(.presentCargeSelectionView(true))
        }
      }
    )
  }
  
  var chargeDurationView: some View {
    Picker(
      L10n.Description.Row.length,
      selection: viewStore.binding(
        get: \.selectedDuration,
        send: DescriptionAction.setDuraration
      )
    ) {
      ForEach(1..<Times.allCases.count, id: \.self) {
        Text(Times.allCases[$0].description)
          .contentShape(Rectangle())
          .foregroundColor(Color(.label))
      }
    }
  }
  
  var blockedOthersView: some View {
    ToggleButton(
      label: L10n.Description.Row.didBlockOthers,
      isOn: viewStore.binding(\.$blockedOthers)
    )
    .accessibleAnimation(.easeIn(duration: 0.2), value: viewStore.blockedOthers)
  }
  
  var verhicleEmtpyView: some View {
    ToggleButton(
      label: "Das Fahrzeug war verlassen",
      isOn: viewStore.binding(\.$verhicleEmpty)
    )
    .accessibleAnimation(.easeIn(duration: 0.2), value: viewStore.verhicleEmpty)
  }
  
  var hazardLightsView: some View {
    ToggleButton(
      label: "Das Fahrzeug hatte die Warnblinkanlage aktiviert",
      isOn: viewStore.binding(\.$hazardLights)
    )
    .accessibleAnimation(.easeIn(duration: 0.2), value: viewStore.hazardLights)
  }
  
  var expiredTuvView: some View {
    ToggleButton(
      label: "Die TÜV-Plakette war abgelaufen",
      isOn: viewStore.binding(\.$expiredTuv)
    )
    .accessibleAnimation(.easeIn(duration: 0.2), value: viewStore.expiredTuv)
  }
  
  var expiredEcoView: some View {
    ToggleButton(
      label: "Die Umwelt-Plakette fehlte oder war ungültig",
      isOn: viewStore.binding(\.$expiredEco)
    )
    .accessibleAnimation(.easeIn(duration: 0.2), value: viewStore.expiredEco)
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
