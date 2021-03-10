//
//  MainView.swift
//  weg-li
//
//  Created by Stefan Trauth on 08.10.19.
//  Copyright © 2019 Stefan Trauth. All rights reserved.
//

import SwiftUI

struct MainView: View {
    @State private var showReportForm: Bool = false
    @State private var showPersonalData: Bool = false
    
    @State private var wasReportEdited = false
    @State private var presentDraftAlert = false
    
    @State private var showingSheet = false
    @State private var reports = [Report]() // TODO: Inject
    
    @EnvironmentObject private var store: AppStore
    
    var body: some View {
        NavigationView {
            ZStack {
                List(reports, id: \.uuid) { report in
                    Text(report.date.humandReadableDate) // TODO: Replace with saved reports
                }
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        NavigationLink(
                            destination: ReportForm().environmentObject(store),
                            isActive: $showReportForm,
                            label: {
                                addButton
                            }
                        )
                        
                    }
                }
            }
            .navigationBarTitle("Reports")
            .navigationBarItems(trailing: contactDataIcon)
        }
        .sheet(isPresented: $showPersonalData) {
            PersonalData(
                isPresented: $showPersonalData,
                viewModel: PersonalDataViewModel(
                    model: store.state.contact
                )
            )
            .environmentObject(store)
        }
    }
    
    private var addButton: some View {
        Button(
            action: { showReportForm.toggle() },
            label: {
                VStack {
                    Text("+")
                        .font(.system(.largeTitle))
                        .frame(width: 70, height: 70)
                        .foregroundColor(.white)
                }
            })
            .accessibility(label: Text("Add Report"))
            .background(Color.gray)
            .cornerRadius(35)
            .padding()
            .shadow(color: Color.primary.opacity(0.3),
                    radius: 3,
                    x: 3,
                    y: 3)
    }
    
    private var contactDataIcon: some View {
        Button(action: {
            showPersonalData.toggle()
        }, label: {
            Text("Contact Data")
        })
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .preferredColorScheme(.dark)
    }
}
