//
//  DataRow.swift
//  Wegli
//
//  Created by Malte Bünz on 04.06.20.
//  Copyright © 2020 Stefan Trauth. All rights reserved.
//

import SwiftUI

struct DataRow: View {
    let type: RowType
    @Binding var text: String
    @Binding var isValid: Bool
    
    @State private var isPopoverPresented: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(type.label)
                    .font(.callout)
                    .foregroundColor(.gray)
                if !isValid {
                    Button(action: {
                        self.isPopoverPresented.toggle()
                    }) {
                        Image(systemName: "exclamationmark.circle.fill")
                            .foregroundColor(.orange)
                            .accessibility(hidden: true)
                    }
                    .alert(isPresented: $isPopoverPresented) {
                        Alert(
                            title: Text("\(type.label) darf nicht leer sein."),
                            dismissButton: .default(Text("Ok"))
                        )
                    }
                }
            }
            TextField(type.placeholder, text: $text)
                .multilineTextAlignment(.leading)
                .keyboardType(type.keyboardType)
                .textFieldStyle(PlainTextFieldStyle())
        }
    }
}

struct DataRow_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            DataRow(type: .zipCode, text: .constant("Hello World!"), isValid: .constant(false))
            DataRow(type: .firstName, text: .constant("Hello World!"), isValid: .constant(false))
            DataRow(type: .lastName, text: .constant("Hello World!"), isValid: .constant(false))
            DataRow(type: .street, text: .constant("Hello World!"), isValid: .constant(false))
        }
    }
}

enum RowType {
    case firstName, lastName, street, town, zipCode, phone
    
    var label: String {
        switch self {
        case .firstName: return "Vorname"
        case .lastName: return "Nachname"
        case .street: return "Strasse"
        case .town: return "Stadt"
        case .zipCode: return "PLZ"
        case .phone: return "Telefon"
        }
    }
    
    var placeholder: String {
        switch self {
        case .firstName: return "Max"
        case .lastName: return "Mustermann"
        case .street: return "Siemensallee, 17"
        case .town: return "Mannheim"
        case .zipCode: return "76341"
        case .phone:return "0123 5346435"
        }
    }
    
    var keyboardType: UIKeyboardType {
        switch self {
        case .phone: return .numberPad
        default: return .namePhonePad
        }
    }
}

