// Created for weg-li in 2021.

import ComposableArchitecture
import SwiftUI

struct SettingsView: View {
    @Environment(\.colorScheme) private var colorScheme

    let store: Store<SettingsState, SettingsAction>
    @ObservedObject private var viewStore: ViewStore<SettingsState, SettingsAction>

    internal init(store: Store<SettingsState, SettingsAction>) {
        self.store = store
        viewStore = ViewStore(store)
    }

    var body: some View {
        Form {
            Section {
                NavigationLink(
                    destination: ContactView(
                        store: store.scope(
                            state: \.contact,
                            action: SettingsAction.contact
                        )
                    ),
                    label: {
                        HStack {
                            Text(L10n.Contact.widgetTitle)
                            Spacer()
                        }
                    }
                )
            }
            Section {
                Button(
                    action: { viewStore.send(.openImprintTapped) },
                    label: {
                        HStack {
                            Text(L10n.Settings.Row.imprint)
                            Spacer()
                            linkIcon
                        }
                    }
                )
                Button(
                    action: { viewStore.send(.donateTapped) },
                    label: {
                        HStack {
                            Text(L10n.Settings.Row.donate)
                            Spacer()
                            linkIcon
                        }
                    }
                )
            }
            Section(
                header: Text(L10n.Settings.Section.projectTitle)
            ) {
                Button(
                    action: { viewStore.send(.openLicensesRowTapped) },
                    label: {
                        HStack {
                            Text(L10n.Settings.Row.licenses)
                            Spacer()
                            linkIcon
                        }
                    }
                )
                Button(
                    action: { viewStore.send(.openGitHubProjectTapped) },
                    label: {
                        HStack {
                            gitHubLogo
                            Text(L10n.Settings.Row.contribute)
                            Spacer()
                            linkIcon
                        }
                    }
                )
            }
            versionNumberView
        }
        .foregroundColor(Color(.label))
        .navigationTitle(L10n.Settings.title)
    }

    private var versionNumberView: some View {
        Text("Version: \(Bundle.main.versionNumber).\(Bundle.main.buildNumber)")
            .frame(maxWidth: .infinity)
            .font(.subheadline)
    }

    private var linkIcon: some View {
        Image(systemName: "link.circle.fill")
            .font(.title)
    }

    @ViewBuilder private var gitHubLogo: some View {
        let logo = Image(uiImage: UIImage(named: "GitHub")!)
            .resizable()
            .frame(maxWidth: 32, maxHeight: 32)
        if colorScheme == ColorScheme.dark {
            logo.colorInvert()
        } else {
            logo
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        Preview {
            NavigationView {
                SettingsView(
                    store: .init(
                        initialState: .init(contact: .preview),
                        reducer: .empty,
                        environment: SettingsEnvironment(uiApplicationClient: .live)
                    )
                )
            }
        }
    }
}
