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
                addReportButton
            }
            .navigationBarTitle("Anzeigen") // TODO: l18n
            .navigationBarItems(trailing: contactData)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 8) {
            Image(systemName: "doc.richtext")
                .font(.system(.largeTitle))
                .accessibility(hidden: true)
            Text("Keine gespeicherten Anzeigen") // TODO: l18n
                .font(.system(.title))
                .multilineTextAlignment(.center)
                .padding([.leading, .trailing])
        }
    }
    
    private var addReportButton: some View {
        VStack {
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
                    isActive: viewStore.binding(
                        get: \.showReportWizard,
                        send: HomeAction.showReportWizard
                    ),
                    label: {
                        Button(
                            action: { viewStore.send(.showReportWizard(true)) },
                            label: {
                                Text("+")
                                    .font(.system(.largeTitle))
                                    .frame(width: 70, height: 70)
                                    .foregroundColor(Color(.label))
                                    .accessibility(label: Text("Add Report"))
                                    .background(Color(.systemGray))
                                    .cornerRadius(35)
                                    .padding()
                                    .shadow(color: Color.black.opacity(0.3), radius: 3, x: 3, y: 3)
                            }
                        )
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
                Text("Kontaktdaten") // TODO: l18n
            }
        )
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(
            store: .init(
                initialState: .preview,
                reducer: .empty,
                environment: ()
            )
        )
        //        .preferredColorScheme(.dark)
        //        .environment(\.sizeCategory, .extraExtraLarge)
    }
}
