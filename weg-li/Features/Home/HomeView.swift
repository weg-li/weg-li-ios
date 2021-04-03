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
                    ScrollView {
                        ForEach(viewStore.reports, id: \.uuid) { report in
                            ReportCellView(report: report)
                        }
                        .padding()
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
                    initialState: HomeState(reports: [.preview, .preview, .preview, .preview]),
                    reducer: .empty,
                    environment: ()
                )
            )
        }
//                .preferredColorScheme(.dark)
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

private struct ReportCellView: View {
    let report: Report
    
    var body: some View {
        ZStack {
            HStack {
                VStack(alignment: .leading) {
                    Text(report.date.humandReadableDate)
                        .fontWeight(.bold)
                        .font(.title)
                        .padding(.bottom, 4)
                    HStack(spacing: 12) {
                        Image(systemName: "car")
                            .font(.title2)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(report.car.type), \(report.car.color)")
                            Text(report.car.licensePlateNumber)
                        }
                        .font(.body)
                    }
                    .padding(.bottom, 6)
                    HStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.title2)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(report.charge.time)
                            Text(Report.Charge.charges[report.charge.selectedType])
                        }
                        .font(.body)
                    }
                }
                .padding()
                Spacer()
            }
            .background(Color(.systemGray6))
            .padding(.bottom)
            // Design attempt :D
            VStack {
                HStack {
                    Spacer()
                    Image(systemName: "exclamationmark.octagon")
                        .font(.system(size: 140))
                        .offset(x: 70)
                        .clipped()
                        .blendMode(.overlay)
                }
                Spacer()
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
