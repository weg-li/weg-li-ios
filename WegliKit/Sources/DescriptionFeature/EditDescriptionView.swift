// Created for weg-li in 2021.

import ComposableArchitecture
import Helper
import L10n
import SharedModels
import Styleguide
import SwiftUI

public struct EditDescriptionView: View {
  public typealias S = DescriptionDomain.State
  public typealias A = DescriptionDomain.Action
  
  @Environment(\.presentationMode) var presentationMode
  @Environment(\.isSearching) var isSearching
  
  private let store: StoreOf<DescriptionDomain>
  @ObservedObject private var viewStore: ViewStoreOf<DescriptionDomain>
  
  public init(store: StoreOf<DescriptionDomain>) {
    self.store = store
    self.viewStore = ViewStore(store, observe: { $0 })
  }
    
  public var body: some View {
    Group {
      Section {
        licensePlateView
        
        carBrandView
        
        carColorView
      } header: {
        SectionHeader(text: L10n.Description.Section.Vehicle.copy)
      }
      .textFieldStyle(.plain)
      
      Section {
        chargeTypeView
        
        chargeDurationView
        
        blockedOthersView
        
        vehicleEmptyView
        
        hazardLightsView
        
        expiredTuvView
        
        expiredEcoView
        
        overTwentyEightTonsView
      } header: {
        SectionHeader(text: L10n.Description.Section.Violation.copy)
      }
      
      Section {
        TextEditor(text: viewStore.$note)
          .font(.body)
          .clipShape(RoundedRectangle(cornerRadius: 4))
      } header: {
        SectionHeader(text: "Hinweise")
      }
    }
  }
  
  var licensePlateView: some View {
    TextField(
      L10n.Description.Row.licenseplateNumber,
      text: viewStore.$licensePlateNumber
    )
    .textFieldStyle(.plain)
    .disableAutocorrection(true)
    .textInputAutocapitalization(.characters)
  }
  
  var carBrandView: some View {
    NavigationLink(
      isActive: viewStore.$presentCarBrandSelection,
      destination: {
        CarBrandSelectorView(
          store: self.store.scope(
            state: \.carBrandSelection,
            action: A.carBrandSelection
          )
        )
        .navigationTitle(Text(L10n.Description.Row.carType))
        .navigationBarTitleDisplayMode(.inline)
      },
      label: {
        HStack {
          Text(L10n.Description.Row.carType)
          if let brand = viewStore.carBrandSelection.selectedBrand {
            Spacer()
            Text(brand.title)
          }
        }
        .contentShape(Rectangle())
        .onTapGesture {
          viewStore.send(.set(\.$presentCarBrandSelection, true))
        }
      }
    )
  }
  
  var carColorView: some View {
    Picker(
      L10n.Description.Row.carColor,
      selection: viewStore.$selectedColor
    ) {
      ForEach(1 ..< DescriptionDomain.colors.count, id: \.self) {
        Text(DescriptionDomain.colors[$0].value)
          .contentShape(Rectangle())
          .tag($0)
      }
    }
    .pickerStyle(.menu)
  }
  
  var chargeTypeView: some View {
    NavigationLink(
      isActive: viewStore.$presentChargeSelection,
      destination: {
        ChargeSelectionView(
          store: self.store.scope(
            state: \.chargeSelection,
            action: A.chargeSelection
          )
        )
        .accessibilityAddTraits([.isModal])
        .navigationTitle(Text(L10n.Description.Row.chargeType))
        .navigationBarTitleDisplayMode(.inline)
      },
      label: {
        HStack {
          Text(L10n.Description.Row.chargeType)
          if let charge = viewStore.state.chargeSelection.selectedCharge {
            Spacer()
            Text(charge.text)
          }
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
    Picker(
      L10n.Description.Row.length,
      selection: viewStore.$selectedDuration
    ) {
      ForEach(times, id: \.self) { time in
        Text(Times.times[time] ?? "")
          .contentShape(Rectangle())
      }
    }
    .pickerStyle(.menu)
  }
  
  var blockedOthersView: some View {
    ToggleButton(
      label: L10n.Description.Row.didBlockOthers,
      isOn: viewStore.$blockedOthers
    )
  }
  
  var vehicleEmptyView: some View {
    ToggleButton(
      label: "Das Fahrzeug war verlassen",
      isOn: viewStore.$vehicleEmpty
    )
  }
  
  var hazardLightsView: some View {
    ToggleButton(
      label: "Das Fahrzeug hatte die Warnblinkanlage aktiviert",
      isOn: viewStore.$hazardLights
    )
  }
  
  var expiredTuvView: some View {
    ToggleButton(
      label: "Die TÜV-Plakette war abgelaufen",
      isOn: viewStore.$expiredTuv
    )
  }
  
  var expiredEcoView: some View {
    ToggleButton(
      label: "Die Umwelt-Plakette fehlte oder war ungültig",
      isOn: viewStore.$expiredEco
    )
  }
  
  var overTwentyEightTonsView: some View {
    ToggleButton(
      label: "Fahrzeug über 2,8 t zulässige Gesamtmasse",
      isOn: viewStore.$over28Tons
    )
  }
}

struct Description_Previews: PreviewProvider {
  static var previews: some View {
    Preview {
      EditDescriptionView(
        store: Store(
          initialState: DescriptionDomain.State(),
          reducer: { DescriptionDomain() }
        )
      )
    }
  }
}
