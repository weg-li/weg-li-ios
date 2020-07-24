//
//  DataRow.swift
//  weg-li
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
                .textContentType(type.textContentType)
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
        case .street: return "Max-Brauer-Allee 23"
        case .town: return "Hamburg"
        case .zipCode: return "20095"
        case .phone:return "+491235346435"
        }
    }

    var textContentType: UITextContentType? {
        switch self {
        case .firstName: return .givenName
        case .lastName: return .familyName
        case .street: return .fullStreetAddress
        case .town: return .addressCity
        case .zipCode: return .postalCode
        case .phone: return .telephoneNumber
        }
    }
    
    var keyboardType: UIKeyboardType {
        switch self {
        case .phone: return .phonePad
        default: return .default
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
