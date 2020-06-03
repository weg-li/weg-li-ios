//
//  ReportForm.swift
//  Wegli
//
//  Created by Stefan Trauth on 08.10.19.
//  Copyright © 2019 Stefan Trauth. All rights reserved.
//

import SwiftUI

struct ReportForm: View {
    var body: some View {
        ScrollView {
            VStack {
                Widget(
                    title: Text("Fotos"),
                    state: .completed,
                    content: Images()
                        .eraseToAnyView()
                )
                Widget(
                    title: Text("Ort"),
                    state: .completed,
                    content: Location()
                        .eraseToAnyView()
                )
                Widget(
                    title: Text("Beschreibung"),
                    state: .completed,
                    content: Description()
                        .eraseToAnyView()
                )
                Widget(
                    title: Text("Persönliche Daten"),
                    state: .completed,
                    content: PersonalData()
                    .eraseToAnyView()
                )
                SubmitButton(state: .readyToSubmit(ordnungsamt: "München")) {}
                DiscardButton() {}
            }
        }
    }
}

struct ReportForm_Previews: PreviewProvider {
    static var previews: some View {
        ReportForm()
    }
}
