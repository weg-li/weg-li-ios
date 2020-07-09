//
//  SubmitButton.swift
//  weg-li
//
//  Created by Stefan Trauth on 08.10.19.
//  Copyright © 2019 Stefan Trauth. All rights reserved.
//

import SwiftUI

struct SubmitButtonStyle: ViewModifier {
    let color: Color
    
    func body(content: Content) -> some View {
        content
            .padding()
            .foregroundColor(.white)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

struct ReadySubmitButton: View {
    let ordnungsamt: String
    
    var body: some View {
        HStack {
            Image(systemName: "envelope.fill")
            VStack(alignment: .leading) {
                Text("Anzeige aufgeben").font(.headline)
                Text("Ordnungsamt \(ordnungsamt)").font(.caption)
            }
        }
        .modifier(SubmitButtonStyle(color: .green))
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
        .modifier(SubmitButtonStyle(color: .orange))
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
        .modifier(SubmitButtonStyle(color: .red))
    }
}

struct SubmitButton: View {
    let state: Status
    let action: () -> Void
    
    enum Status {
        case unsupportedLocation
        case missingData
        case readyToSubmit(ordnungsamt: String)
    }
    
    @ViewBuilder var body: some View {
        if case .readyToSubmit(let ordnungsamt) = state {
            return Button(action: action) { ReadySubmitButton(ordnungsamt: ordnungsamt) }
        } else if case .unsupportedLocation = state {
            return Button(action: action) { UnsupportedLocationButton() }
        } else {
            return Button(action: action) { MissingDataButton() }
        }
    }
}

struct SubmitButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            SubmitButton(state: .readyToSubmit(ordnungsamt: "München")) {}
            SubmitButton(state: .unsupportedLocation) {}
            SubmitButton(state: .missingData) {}
        }
    }
}
