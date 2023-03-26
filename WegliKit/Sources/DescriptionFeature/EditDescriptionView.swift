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
      } header: {
        SectionHeader(text: L10n.Description.Section.Violation.copy)
      }
      
      Section {
        TextEditor(text: viewStore.binding(\.$note))
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
      text: viewStore.binding(\.$licensePlateNumber)
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
      selection: viewStore.binding(\.$selectedColor)
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
      isActive: viewStore.binding(\.$presentChargeSelection),
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
      selection: viewStore.binding(\.$selectedDuration)
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
        store: Store(
          initialState: DescriptionDomain.State(),
          reducer: DescriptionDomain()
        )
      )
    }
  }
}
