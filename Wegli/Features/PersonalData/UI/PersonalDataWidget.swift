//
//  PersonalDataWidget.swift
//  Wegli
//
//  Created by Malte Bünz on 04.06.20.
//  Copyright © 2020 Stefan Trauth. All rights reserved.
//

import SwiftUI

struct PersonalDataWidget: View {
    let viewModel: PersonalDataViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            row(callout: "Name", content: "\(viewModel.firstName) \(viewModel.name)")
            row(callout: "Straße", content: viewModel.street)
            row(callout: "Stadt", content: "\(viewModel.zipCode) \(viewModel.town)")
            row(callout: "Telefon", content: viewModel.phone)
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
        PersonalDataWidget(viewModel: PersonalDataViewModel())
    }
}
