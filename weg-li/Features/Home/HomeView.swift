// Created for weg-li in 2021.

import ComposableArchitecture
import SwiftUI

struct HomeView: View {
    private let store: Store<HomeState, HomeAction>
    @ObservedObject private var viewStore: ViewStore<HomeState, HomeAction>

    init(store: Store<HomeState, HomeAction>) {
        self.store = store
        viewStore = ViewStore(store)
    }

    var body: some View {
        NavigationView {
            ZStack {
                if viewStore.reports.isEmpty {
                    emptyStateView
                } else {
                    ScrollView {
                        ForEach(viewStore.reports, id: \.id) { report in
                            ReportCellView(report: report)
                        }
                        .padding()
                    }
                }
                addReportButton
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .navigationBarTitle(L10n.Home.navigationBarTitle)
            .navigationBarItems(trailing: contactData)
            .onAppear { viewStore.send(.onAppear) }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "doc.richtext")
                .font(Font.system(.largeTitle))
                .accessibility(hidden: true)
            Text(L10n.Home.emptyStateCopy)
                .font(.system(.title))
                .multilineTextAlignment(.center)
                .padding()
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
                        .padding(24)
                        .accessibility(label: Text(L10n.Home.A11y.addReportButtonLabel))
                    }
                )
            }
        }
    }

    private var contactData: some View {
        NavigationLink(
            destination: SettingsView(
                store: store.scope(
                    state: \.settings,
                    action: HomeAction.settings
                )
            ),
            label: {
                Image(systemName: "gearshape")
                    .font(Font.system(.title2).bold())
            }
        )
        .accessibility(label: Text(L10n.Settings.title))
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        Preview {
            HomeView(
                store: .init(
                    initialState: HomeState(reports: [.preview, .preview, .preview, .preview]),
                    reducer: .empty,
                    environment: ()
                )
            )
        }
    }
}
