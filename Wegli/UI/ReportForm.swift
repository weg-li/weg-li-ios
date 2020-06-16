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
    
    @State private var editDescription = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    Widget(
                        title: Text("Fotos"),
                        isCompleted: !store.state.report.images.isEmpty) {
                            Images()
                    }
                    Widget(
                        title: Text("Ort"),
                        isCompleted: store.state.location.location != .zero) {
                            Location()
                    }
                    Widget(
                        title: Text("Beschreibung"),
                        isCompleted: store.state.report.isDescriptionValid) {
                            DescriptionWidgetView().environmentObject(self.store)
                    }
                    Widget(
                        title: Text("Persönliche Daten"),
                        isCompleted: store.state.contact?.isValid ?? false) {
                            PersonalDataWidget(contact: self.store.state.contact)
                    }
                    MailContentView()
                        .padding([.top, .bottom], 16)
                }
            }
            .padding(.bottom)
            .navigationBarTitle("Formular", displayMode: .inline)
        }
    }
}

struct ReportForm_Previews: PreviewProvider {
    static var previews: some View {
        ReportForm()
    }
}
