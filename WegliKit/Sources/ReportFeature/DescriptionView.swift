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
    var chargeType: String {
      description.chargeSelection.selectedCharge?.text ?? ""
    }
    var brand: String {
      description.carBrandSelection.selectedBrand?.title ?? ""
    }
    var color: String {
      DescriptionDomain.colors[description.selectedColor].value
    }
    
    init(state: DescriptionDomain.State) {
      self.description = state
    }
  }
  
  let viewState: ViewState
  let buttonAction: () -> Void
  
  public init(state: DescriptionDomain.State, action: @escaping () -> Void) {
    self.viewState = .init(state: state)
    self.buttonAction = action
  }
  
  public var body: some View {
    VStack(alignment: .leading) {
      VStack(alignment: .leading, spacing: .grid(3)) {
        row(title: L10n.Description.Row.licenseplateNumber, content: viewState.description.licensePlateNumber)
        
        row(title: L10n.Description.Row.carType, content: viewState.brand)
        
        row(title: L10n.Description.Row.carColor, content: viewState.color)
        
        row(title: L10n.Description.Row.chargeType, content: viewState.chargeType)
        
        row(title: L10n.Description.Row.length, content: viewState.description.time)
        
        VStack(alignment: .leading, spacing: .grid(3)) {
          toggleRow(
            label: L10n.Description.Row.didBlockOthers,
            value: viewState.description.blockedOthers
          )
          
          toggleRow(
            label: "Das Fahrzeug war verlassen",
            value: viewState.description.vehicleEmpty
          )
          
          toggleRow(
            label: "Das Fahrzeug hatte die Warnblinkanlage aktiviert",
            value: viewState.description.hazardLights
          )
          
          toggleRow(
            label: "Die TÜV-Plakette war abgelaufen",
            value: viewState.description.expiredTuv
          )
          
          toggleRow(
            label: "Die Umwelt-Plakette fehlte oder war ungültig",
            value: viewState.description.expiredEco
          )
          
          toggleRow(
            label: "Fahrzeug über 2,8 t zulässige Gesamtmasse",
            value: viewState.description.over28Tons
          )
        }
      }
      .accessibilitySortPriority(1)
      .accessibilityElement(children: .combine)
      
      Button(
        action: buttonAction,
        label: {
          Label(L10n.Description.EditButton.copy, systemImage: "square.and.pencil")
            .contentShape(Rectangle())
            .frame(maxWidth: .infinity)
        }
      )
      .accessibilitySortPriority(2)
      .buttonStyle(.edit())
      .padding(.top)
    }
    .contentShape(Rectangle())
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

#Preview {
  DescriptionView(state: .init(model: .mock), action: {})
}
