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
        VStack(spacing: 12) {
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
                            label: { Text("+") }
                        )
                        .buttonStyle(AddReportButtonStyle())
                        .padding()
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
        Group {
            HomeView(
                store: .init(
                    initialState: HomeState(
                        reports: [.preview, .preview]
                    ),
                    reducer: .empty,
                    environment: ()
                )
            )
        }
        //        .preferredColorScheme(.dark)
        //        .environment(\.sizeCategory, .extraExtraLarge)
    }
}

private struct AddReportButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.largeTitle))
            .frame(width: 70, height: 70)
            .lineLimit(1)
            .foregroundColor(Color(.label))
            .background(configuration.isPressed ? Color(.systemGray2) : Color(.systemGray3))
            .clipShape(RoundedRectangle(cornerRadius: 35))
            .shadow(color: Color.black.opacity(0.3), radius: 6, x: 3, y: 3)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .accessibility(label: Text("Add Report"))
    }
}
