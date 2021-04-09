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
    let diameter: CGFloat = 70

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.largeTitle))
            .frame(width: diameter, height: diameter)
            .lineLimit(1)
            .foregroundColor(.white)
            .background(Color.wegliBlue)
            .clipShape(RoundedRectangle(cornerRadius: diameter / 2))
            .overlay(
                RoundedRectangle(cornerRadius: diameter / 2)
                    .stroke(Color.white, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.3), radius: 6, x: 3, y: 3)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
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
                            Text("\(report.description.type), \(report.description.color)")
                            Text(verbatim: report.description.licensePlateNumber)
                        }
                        .font(.body)
                    }
                    .padding(.bottom, 6)
                    HStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.title2)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(report.description.time)
                            Text(DescriptionState.charges[report.description.selectedType])
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
            .accessibility(hidden: true)
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
