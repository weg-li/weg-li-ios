//
//  MainView.swift
//  weg-li
//
//  Created by Stefan Trauth on 08.10.19.
//  Copyright © 2019 Stefan Trauth. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct HomeView: View {
    private let store: Store<HomeState, HomeAction>
    @ObservedObject private var viewStore: ViewStore<HomeState, HomeAction>
    
    init(store: Store<HomeState, HomeAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewStore.reports.isEmpty {
                    emptyStateView
                } else {
                    List(viewStore.reports, id: \.uuid) { report in
                        Text(report.date.humandReadableDate) // TODO: Replace with saved reports
                    }
                }
                addReport
            }
            .navigationBarTitle("Reports")
            .navigationBarItems(trailing: contactData)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 8) {
            Image(systemName: "doc.richtext")
                .font(.system(size: 32))
            Text("Keine Reports")
                .font(.system(size: 24))
        }
    }
    
    private var addReport: some View {
        var addButton: some View {
            Text("+")
                .font(.system(.largeTitle))
                .frame(width: 70, height: 70)
                .foregroundColor(.white)
                .accessibility(label: Text("Add Report"))
                .background(Color.gray)
                .cornerRadius(35)
                .padding()
                .shadow(color: Color.black.opacity(0.3), radius: 3, x: 3, y: 3)
        }
        return VStack {
            Spacer()
            HStack {
                Spacer()
                NavigationLink(
                    destination: ReportForm(
                        store: store.scope(
                            state: \.reportDraft,
                            action: HomeAction.report
                        )
                    ),
                    label: {
                        addButton
                    }
                    
                )
            }
        }
    }
    
    private var contactData: some View {
        let contactDataStore = store.scope(
            state: \.contact,
            action: HomeAction.contact
        )
        return NavigationLink(
            destination: ContactView(store: contactDataStore),
            label: {
                Text("Contact Data")
            }
        )
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(store: .init(initialState: .preview, reducer: .empty, environment: ()))
            .preferredColorScheme(.dark)
    }
}
