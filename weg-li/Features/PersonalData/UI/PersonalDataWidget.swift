//
//  PersonalDataWidget.swift
//  weg-li
//
//  Created by Malte Bünz on 04.06.20.
//  Copyright © 2020 Stefan Trauth. All rights reserved.
//

import SwiftUI

struct PersonalDataWidget: View {
    let contact: Contact?
    
    @ViewBuilder var body: some View {
        guard let contact = contact, contact.isValid else {
            return Text("Keine Kontaktdaten angegeben")
        }
        return VStack(alignment: .leading, spacing: 10) {
            row(callout: "Name", content: ("\(contact.firstName) \(contact.name)"))
            row(callout: "Straße", content: contact.address.street)
            row(callout: "Stadt", content: "\(contact.address.zipCode) \(contact.address.town)")
            row(callout: "Telefon", content: contact.phone)
            Text("Die Anzeige kann nur bearbeitet werden, wenn du richtige Angaben zu deiner Person machst.")
                .font(.footnote)
                .foregroundColor(.gray)
        }
    }
    
    private func row(callout: String, content: String) -> some View {
        HStack {
            Text(callout)
                .font(.callout)
                .fontWeight(.bold)
            Spacer()
            Text(content)
                .foregroundColor(.gray)
        }
    }
}

struct PersonalDataWidget_Previews: PreviewProvider {
    static var previews: some View {
        PersonalDataWidget(contact: .init(firstName: "", name: "", address: .init(street: "", zipCode: "", town:   ""), phone: "", mail: ""))
    }
}
