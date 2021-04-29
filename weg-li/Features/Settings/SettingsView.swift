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
            }
            Section {
                Button(
                    action: { viewStore.send(.openGitHubProjectTapped) },
                    label: { githubView }
                )
            }
            versionNumberView
        }
        .foregroundColor(Color(.label))
        .navigationTitle(L10n.Settings.title)
    }
    
    private var githubView: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                Text("weg-li ist open source")
                    .font(.system(.headline, design: .monospaced))
                    .foregroundColor(.white)
                VStack(alignment: .leading) {
                    Text("Dir fehlt ein feature oder du willst einen bug fixen?")
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(Color.hex(0x40C8DD))
                }
                .padding(.top, 4)
            }
            Spacer()
            Image(uiImage: UIImage(named: "GitHub")!)
                .resizable()
                .frame(maxWidth: 32, maxHeight: 32)
                .colorInvert()
                .padding(.leading, 6)
        }
        .padding([.top, .bottom], 4)
        .background(
            Color.hex(0x483C46)
                .padding(-20)
        )
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

extension Color {
    public static func hex(_ hex: UInt) -> Self {
        Self(
            red: Double((hex & 0xff0000) >> 16) / 255,
            green: Double((hex & 0x00ff00) >> 8) / 255,
            blue: Double(hex & 0x0000ff) / 255,
            opacity: 1
        )
    }
}
