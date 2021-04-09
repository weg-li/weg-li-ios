// Created for weg-li in 2021.

import SwiftUI

struct SubmitButtonStyle: ViewModifier {
    let color: Color
    let disabled: Bool

    func body(content: Content) -> some View {
        content
            .padding()
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .background(disabled ? Color(.systemGray2) : color)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

struct ReadySubmitButton: View {
    let ordnungsamt: String?
    var disabled: Bool = false

    var body: some View {
        HStack {
            Image(systemName: "envelope.fill")
            VStack(alignment: .leading) {
                Text("Anzeige aufgeben").font(.headline)
                if let amt = ordnungsamt {
                    Text("Ordnungsamt \(amt)").font(.caption)
                }
            }
        }
        .modifier(SubmitButtonStyle(color: .wegliBlue, disabled: disabled))
    }
}

struct MissingDataButton: View {
    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.circle.fill")
            VStack(alignment: .leading) {
                Text("Bitte gib alle nötigen Daten an").font(.headline)
            }
        }
        .modifier(SubmitButtonStyle(color: .orange, disabled: false))
    }
}

struct UnsupportedLocationButton: View {
    var body: some View {
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

struct SubmitButton: View {
    let state: Status
    var disabled: Bool = false
    let action: () -> Void

    enum Status {
        case unsupportedLocation
        case missingData
        case readyToSubmit(ordnungsamt: String?)
    }

    var body: some View {
        Button(action: action) { () -> AnyView in
            switch state {
            case .missingData:
                return AnyView(MissingDataButton())
            case .unsupportedLocation:
                return AnyView(UnsupportedLocationButton())
            case let .readyToSubmit(ordnungsamt: ordnungsamt):
                return AnyView(
                    ReadySubmitButton(
                        ordnungsamt: ordnungsamt,
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
            ReadySubmitButton(ordnungsamt: "Hamburg", disabled: true)
            ReadySubmitButton(ordnungsamt: "Hamburg", disabled: false)
            SubmitButton(state: .unsupportedLocation) {
                print("yes")
            }
            SubmitButton(state: .missingData) {
                print("yes")
            }
            SubmitButton(state: .readyToSubmit(ordnungsamt: "Hamburg")) {
                print("yes")
            }
        }
    }
}
