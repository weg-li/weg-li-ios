// Created for weg-li in 2021.

import ComposableArchitecture
import ContactFeature
import Helper
import L10n
import Styleguide
import SwiftUI
import SwiftUINavigation

public struct SettingsView: View {
  public typealias S = SettingsDomain.State
  public typealias A = SettingsDomain.Action
  
  @Environment(\.colorScheme) private var colorScheme
  
  let store: Store<S, A>
  @ObservedObject private var viewStore: ViewStore<S, A>
  
  public init(store: Store<S, A>) {
    self.store = store
    self.viewStore = ViewStore(store)
  }
  
  public var body: some View {
    Form {
      Section {
        Button(
          action: { viewStore.send(.setDestination(.accountSettings)) },
          label: {
            HStack {
              Label("Account", systemImage: "person.circle")
                .labelStyle(.titleOnly)
              Spacer()
              Image(systemName: "chevron.right")
            }
          }
        )
      }
      
      Section(header: Label("Allgemein", systemImage: "hammer.fill")) {
        Toggle(
          isOn: viewStore.binding(
            get: \.userSettings.showsAllTextRecognitionSettings,
            send: { A.userSettings(.setShowsAllTextRecognitionResults($0)) }
          ),
          label: {
            Label("Alle Ergebnisse der Nummernschild Erkennung anzeigen", systemImage: "text.magnifyingglass")
              .labelStyle(.titleOnly)
          }
        )
        
        Toggle(
          isOn: viewStore.binding(
            get: \.userSettings.alwaysSendNotice,
            send: { A.userSettings(.onAlwaysSendNotice($0)) }
          ),
          label: {
            VStack(alignment: .leading) {
              Text("Meldung immer direkt senden")
                .font(.body)
                .padding(.bottom)
              Text(
                viewStore.state.userSettings.alwaysSendNotice
                ? "Die Meldung wird direkt an die Behörde gesendet."
                : "Die Meldung wird hochgeladen und du kannst sie noch einmal auf der Webseite prüfen bevor du sie versendest."
              )
              .font(.subheadline)
            }
          }
        )
      }
      .headerProminence(.increased)
      
      Section(
        header: Label(L10n.Settings.Section.projectTitle, systemImage: "chevron.left.forwardslash.chevron.right")
      ) {
        Button(
          action: { viewStore.send(.openImprintTapped) },
          label: {
            HStack {
              Text(L10n.Settings.Row.imprint)
              Spacer()
              linkIcon
            }
            .padding(.vertical, 4)
          }
        )
        .accessibilityAddTraits([.isLink])
        
        Button(
          action: { viewStore.send(.donateTapped) },
          label: {
            HStack {
              Text(L10n.Settings.Row.donate)
              Spacer()
              linkIcon
            }
            .padding(.vertical, 4)
          }
        )
        .accessibilityAddTraits([.isLink])
        
        Button(
          action: { viewStore.send(.openLicensesRowTapped) },
          label: {
            HStack {
              Text(L10n.Settings.Row.licenses)
              Spacer()
              linkIcon
            }
            .padding(.vertical, 4)
          }
        )
      }
      .headerProminence(.increased)
      
      Section {
        Button(
          action: { viewStore.send(.openGitHubProjectTapped) },
          label: { githubView }
        )
      }
      versionNumberView
    }
    .navigationDestination(
      unwrapping: viewStore.binding(get: \.destination, send: A.setDestination),
      case: /S.Destination.accountSettings,
      destination: { _ in
        AccountSettingsView(
          store: store.scope(
            state: \.accountSettingsState,
            action: A.accountSettings
          )
        )
      }
    )
    .foregroundColor(Color(.label))
    .navigationTitle(L10n.Settings.title)
  }
  
  var githubView: some View {
    VStack {
      HStack(alignment: .top) {
        VStack(alignment: .leading) {
          Text("weg-li ist open source")
            .font(.system(.headline, design: .monospaced))
            .foregroundColor(.white)
            .padding(.bottom, .grid(1))
          VStack(alignment: .leading) {
            Text("Dir fehlt ein _feature_ oder du willst einen _bug_ fixen?")
              .multilineTextAlignment(.leading)
              .font(.system(.body, design: .monospaced))
              .foregroundColor(.gitHubBannerForeground)
              .fixedSize(horizontal: false, vertical: true)
          }
        }
        Spacer()
        // swiftlint:disable:next force_unwrapping
        Image(uiImage: UIImage(named: "GitHub")!)
          .resizable()
          .frame(maxWidth: 32, maxHeight: 32)
          .colorInvert()
          .padding(.leading, .grid(2))
      }
      
      HStack {
        Text("Projekt auf GitHub anzeigen")
        Spacer()
        Image(systemName: "arrow.up.right")
      }
      .padding(.top, .grid(1))
      .font(.system(.body, design: .monospaced))
      .foregroundColor(Color(.hex(0xffffc7)))
    }
    .padding([.top, .bottom], .grid(1))
    .background(
      LinearGradient(
        gradient: Gradient(colors: [Color.gitHubBannerBackground, Color(.hex(0x2d1c3d))]), startPoint: .top, endPoint: .bottom
      )
      .padding(-20)
    )
  }
  
  var versionNumberView: some View {
    Text("Version: \(Bundle.main.versionNumber).\(Bundle.main.buildNumber)")
      .frame(maxWidth: .infinity)
      .font(.subheadline)
  }
  
  var linkIcon: some View {
    Image(systemName: "arrow.up.right")
      .font(.body)
  }
}

struct SettingsView_Previews: PreviewProvider {
  static var previews: some View {
    Preview {
      NavigationStack {
        SettingsView(
          store: .init(
            initialState: .init(
              accountSettingsState: .init(accountSettings: .init(apiToken: "")),
              userSettings: .init(showsAllTextRecognitionSettings: false)
            ),
            reducer: SettingsDomain()
          )
        )
      }
    }
  }
}
