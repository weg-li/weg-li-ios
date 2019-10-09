//
//  PersonalData.swift
//  Wegli
//
//  Created by Stefan Trauth on 09.10.19.
//  Copyright © 2019 Stefan Trauth. All rights reserved.
//

import SwiftUI

private struct DataRow: View {
    let title: Text
    let placeholder: String
    @Binding var binding: String
    
    var body: some View {
        HStack {
            title
            Spacer()
            TextField(placeholder, text: $binding).multilineTextAlignment(.trailing)
        }
    }
}

struct PersonalData: View {
    @State private var name = ""
    @State private var street = ""
    @State private var town = ""
    @State private var phone = ""
    
    var body: some View {
        VStack {
            DataRow(title: Text("Name"), placeholder: "Max Mustermann", binding: $name)
            DataRow(title: Text("Straße, Hausnr."), placeholder: "Siemensallee, 17", binding: $street)
            DataRow(title: Text("PLZ Ort"), placeholder: "76341 Mannheim", binding: $town)
            DataRow(title: Text("Telefon"), placeholder: "0173 2234 6642", binding: $phone)
        }
    }
}

struct PersonalData_Previews: PreviewProvider {
    static var previews: some View {
        PersonalData()
    }
}
