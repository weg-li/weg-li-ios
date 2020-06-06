//
//  ReportForm.swift
//  Wegli
//
//  Created by Stefan Trauth on 08.10.19.
//  Copyright © 2019 Stefan Trauth. All rights reserved.
//

import SwiftUI

struct ReportForm: View {
    @Environment(\.environment) var environmentContainer: EnvironmentContainer
    
    var body: some View {
        let pvm = PersonalDataViewModel(repository: environmentContainer.personalDataRepository)
        return ScrollView {
            VStack {
                Widget(
                    title: Text("Fotos"),
                    isCompleted: true,
                    content: Images()
                        .eraseToAnyView()
                )
                Widget(
                    title: Text("Ort"),
                    isCompleted: true,
                    content: Location()
                        .eraseToAnyView()
                )
                Widget(
                    title: Text("Beschreibung"),
                    isCompleted: true,
                    content: Description()
                        .eraseToAnyView()
                )
                Widget(
                    title: Text("Persönliche Daten"),
                    isCompleted: pvm.isFormValid,
                    content: PersonalDataWidget(viewModel: pvm)
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
