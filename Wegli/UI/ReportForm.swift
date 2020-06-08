//
//  ReportForm.swift
//  Wegli
//
//  Created by Stefan Trauth on 08.10.19.
//  Copyright © 2019 Stefan Trauth. All rights reserved.
//

import SwiftUI

struct ReportForm: View {
    @EnvironmentObject private var store: AppStore
    
    var body: some View {
        ScrollView {
            VStack {
                Widget(
                    title: Text("Fotos"),
                    isCompleted: true) {
                        Images()
                    }
                Widget(
                    title: Text("Ort"),
                    isCompleted: true) {
                        Location()
                    }
                Widget(
                    title: Text("Beschreibung"),
                    isCompleted: true) {
                        Description()
                    }
                Widget(
                    title: Text("Persönliche Daten"),
                    isCompleted: store.state.contact?.isValid ?? false) {
                        PersonalDataWidget(contact: self.store.state.contact)
                    }
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
