//
//  MainView.swift
//  Wegli
//
//  Created by Stefan Trauth on 08.10.19.
//  Copyright © 2019 Stefan Trauth. All rights reserved.
//

import SwiftUI

struct MainView: View {
    @State private var showReportForm: Bool = false
    @State private var showPersonalData: Bool = false
    @Environment(\.environment) var environment: EnvironmentContainer
    
    var body: some View {
        NavigationView {
            VStack {
                Button(action: {
                    self.showReportForm.toggle()
                }) {
                    VStack {
                        Image(systemName: "plus.circle.fill")
                            .iconModifier()
                        Text("Neue Anzeige")
                    }
                    .font(.headline)
                }
            }
            .navigationBarTitle("weg-li")
            .navigationBarItems(trailing:
                Button(action: {
                    self.showPersonalData.toggle()
                }, label: {
                    Image(systemName: "person.circle.fill")
                        .iconModifier()
                })
            )
            .sheet(isPresented: $showReportForm) {
                ReportForm()
            }
        }
        .sheet(isPresented: $showPersonalData) {
            PersonalData(isPresented: self.$showPersonalData, viewModel: PersonalDataViewModel(repository: self.environment.personalDataRepository))
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
