// Created for weg-li in 2021.

import ComposableArchitecture
import ContactFeature
import Helper
import L10n
import Styleguide
import SwiftUI

public struct SettingsView: View {
  public typealias S = SettingsDomain.State
  public typealias A = SettingsDomain.Action
  
  @Environment(\.colorScheme) private var colorScheme
  
  struct ViewState: Equatable {
    public let alwaysSendNotice: Bool
    public let showsAllTextRecognitionSettings: Bool
    
    init(store: SettingsDomain.State) {
      self.alwaysSendNotice = store.userSettings.alwaysSendNotice
      self.showsAllTextRecognitionSettings = store.userSettings.showsAllTextRecognitionSettings
    }
  }
  
  let store: StoreOf<SettingsDomain>
  
  public init(store: StoreOf<SettingsDomain>) {
    self.store = store
  }
  
  public var body: some View {
    WithViewStore(self.store, observe: ViewState.init) { viewStore in
      Form {
        Section {
          Button(
            action: { viewStore.send(.accountSettingsButtonTapped) },
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
        
        Section(header: Label("Meldung", systemImage: "gearshape.2.fill")) {
          VStack(alignment: .leading) {
            Toggle(
              isOn: viewStore.binding(
                get: \.alwaysSendNotice,
                send: { .userSettings(.onAlwaysSendNotice($0)) }
              ),
              label: {
                Text("Meldung immer direkt senden")
                  .font(.body)
                  .padding(.bottom)
              }
            )
            .padding(.bottom)

            HStack {
              Image(systemName: "info.circle")
              Text(
                viewStore.state.alwaysSendNotice
                ? "Die Meldung wird direkt an die Behörde gesendet."
                : "Die Meldung wird hochgeladen und du kannst sie noch einmal auf der Webseite prüfen bevor du sie versendest."
              )
            }
            .font(.system(.caption, design: .default, weight: .light))
          }
        }
        .headerProminence(.increased)
        
        Section(
          header: Label(L10n.Settings.Section.projectTitle, systemImage: "terminal.fill")
        ) {
          Button(
            action: { viewStore.send(.openImprintTapped) },
            label: {
              HStack {
                Text(L10n.Settings.Row.imprint)
                Spacer()
                linkIcon
              }
              .padding(.vertical, .grid(1))
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
              .padding(.vertical, .grid(1))
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
              .padding(.vertical, .grid(1))
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
        store: self.store.scope(
          state: \.$destination.accountSettings,
          action: \.destination.accountSettings
        ),
        destination: AccountSettingsView.init
      )
      .foregroundColor(Color(.label))
      .navigationTitle(L10n.Settings.title)
    }
  }
  
  @ViewBuilder
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
        Image(uiImage: UIImage(named: "GitHub", in: .module, with: nil)!)
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
            reducer: { SettingsDomain() }
          )
        )
      }
    }
  }
}
