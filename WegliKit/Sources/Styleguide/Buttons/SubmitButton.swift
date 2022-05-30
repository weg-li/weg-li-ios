// Created for weg-li in 2021.

import L10n
import SwiftUI

public struct SubmitButtonStyle: ViewModifier {
  public init(color: Color, disabled: Bool) {
    self.color = color
    self.disabled = disabled
  }
  
  let color: Color
  let disabled: Bool
  
  public func body(content: Content) -> some View {
    content
      .padding()
      .foregroundColor(.white)
      .frame(maxWidth: .infinity)
      .disabled(disabled)
      .background(disabled ? Color(.systemGray2) : color)
      .clipShape(RoundedRectangle(cornerRadius: 10))
  }
}

public struct ReadySubmitButton: View {
  public init(district: String?, disabled: Bool = false) {
    self.district = district
    self.disabled = disabled
  }
  
  let district: String?
  var disabled: Bool = false
  
  public var body: some View {
    HStack(spacing: .grid(4)) {
      Image(systemName: "envelope.fill")
        .font(.title2)
      VStack(alignment: .leading, spacing: .grid(1)) {
        Text(L10n.Button.Submit.title)
          .font(.headline)
        if let district = district {
          Label(L10n.Button.Submit.district(district), systemImage: "mappin.and.ellipse")
            .labelStyle(.titleOnly)
            .font(.subheadline)
        }
      }
    }
    .modifier(SubmitButtonStyle(color: .wegliBlue, disabled: disabled))
  }
}

public struct MissingDataButton: View {
  public var body: some View {
    HStack {
      Image(systemName: "exclamationmark.circle.fill")
      VStack(alignment: .leading) {
        Text("Bitte gib alle nötigen Daten an").font(.headline)
      }
    }
    .modifier(SubmitButtonStyle(color: .orange, disabled: false))
  }
}

public struct UnsupportedLocationButton: View {
  public var body: some View {
    HStack {
      Image(systemName: "xmark.circle.fill")
      VStack(alignment: .leading) {
        Text("Anzeige an diesem Ort nicht möglich").font(.headline)
        Text("Du kannst mithelfen auch Anzeigen an diesem Ort zu unterstützen. Bitte nimm Kontakt mit uns auf.").font(.caption)
      }
    }
    .modifier(SubmitButtonStyle(color: .red, disabled: false))
  }
}

public struct SubmitButton: View {
  public init(
    state: SubmitButton.Status,
    disabled: Bool = false,
    action: @escaping () -> Void
  ) {
    self.state = state
    self.disabled = disabled
    self.action = action
  }
  
  public let state: Status
  public var disabled: Bool = false
  public let action: () -> Void
  
  public enum Status {
    case unsupportedLocation
    case missingData
    case readyToSubmit(district: String?)
  }
  
  public var body: some View {
    Button(action: action) { () -> AnyView in
      switch state {
      case .missingData:
        return AnyView(MissingDataButton())
      case .unsupportedLocation:
        return AnyView(UnsupportedLocationButton())
      case let .readyToSubmit(district: district):
        return AnyView(
          ReadySubmitButton(
            district: district,
            disabled: disabled
          )
        )
      }
    }
    .frame(maxWidth: .infinity)
  }
}

struct SubmitButton_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      UnsupportedLocationButton()
      MissingDataButton()
      ReadySubmitButton(district: "Hamburg", disabled: true)
      ReadySubmitButton(district: "Hamburg", disabled: false)
      SubmitButton(state: .unsupportedLocation) {
        print("yes")
      }
      SubmitButton(state: .missingData) {
        print("yes")
      }
      SubmitButton(state: .readyToSubmit(district: "Hamburg")) {
        print("yes")
      }
    }
  }
}
