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
  
  let store: Store<DescriptionDomain.State, DescriptionDomain.Action>
  @ObservedObject private var viewStore: ViewStore<DescriptionDomain.State, DescriptionDomain.Action>
  
  public init(store: Store<DescriptionDomain.State, DescriptionDomain.Action>) {
    self.store = store
    self.viewStore = ViewStore(store)
  }
  
  public var body: some View {
    VStack {
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
        
        vehicleEmptyView
        
        hazardLightsView
        
        expiredTuvView
        
        expiredEcoView
      }
      
      Section(header: Text("Hinweise")) {
        TextEditor(text: viewStore.binding(\.$note))
          .font(.body)
          .clipShape(RoundedRectangle(cornerRadius: 4))
      }
    }
    .onAppear { viewStore.send(.onAppear) }
  }
  
  var licensePlateView: some View {
    TextField(
      L10n.Description.Row.licenseplateNumber,
      text: viewStore.binding(
        get: \.licensePlateNumber,
        send: DescriptionDomain.Action.setLicensePlateNumber
      )
    )
    .disableAutocorrection(true)
    .textInputAutocapitalization(.characters)
  }
  
  var carBrandView: some View {
    NavigationLink(
      isActive: viewStore.binding(
        get: \.presentCarBrandSelection,
        send: DescriptionDomain.Action.presentBrandSelectionView
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
                  .frame(width: .grid(4), height: .grid(4))
                  .foregroundColor(.blue)
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
            send: DescriptionDomain.Action.setCarBrandSearchText
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
        send: DescriptionDomain.Action.setColor
      )
    ) {
      ForEach(1 ..< DescriptionDomain.State.colors.count, id: \.self) {
        Text(DescriptionDomain.State.colors[$0].value)
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
        send: DescriptionDomain.Action.presentChargeSelectionView
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
            send: DescriptionDomain.Action.setChargeTypeSearchText
          ),
          placement: .navigationBarDrawer(displayMode: .always)
        )
        .disableAutocorrection(true)
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
          viewStore.send(.presentChargeSelectionView(true))
        }
      }
    )
  }
  
  var chargeDurationView: some View {
    Picker(
      L10n.Description.Row.length,
      selection: viewStore.binding(
        get: \.selectedDuration,
        send: DescriptionDomain.Action.setDuration
      )
    ) {
      ForEach(viewStore.times, id: \.self) { time in
        Text(Times.times[time] ?? "")
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
  }
  
  var vehicleEmptyView: some View {
    ToggleButton(
      label: "Das Fahrzeug war verlassen",
      isOn: viewStore.binding(\.$vehicleEmpty)
    )
  }
  
  var hazardLightsView: some View {
    ToggleButton(
      label: "Das Fahrzeug hatte die Warnblinkanlage aktiviert",
      isOn: viewStore.binding(\.$hazardLights)
    )
  }
  
  var expiredTuvView: some View {
    ToggleButton(
      label: "Die TÜV-Plakette war abgelaufen",
      isOn: viewStore.binding(\.$expiredTuv)
    )
  }
  
  var expiredEcoView: some View {
    ToggleButton(
      label: "Die Umwelt-Plakette fehlte oder war ungültig",
      isOn: viewStore.binding(\.$expiredEco)
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
