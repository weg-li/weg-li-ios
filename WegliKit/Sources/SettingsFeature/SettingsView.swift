// Created for weg-li in 2021.

import ComposableArchitecture
import ContactFeature
import Helper
import L10n
import Styleguide
import SwiftUI

public struct SettingsView: View {
  @Environment(\.colorScheme) private var colorScheme
  
  let store: Store<SettingsState, SettingsAction>
  @ObservedObject private var viewStore: ViewStore<SettingsState, SettingsAction>
  
  public init(store: Store<SettingsState, SettingsAction>) {
    self.store = store
    viewStore = ViewStore(store)
  }
  
  public var body: some View {
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
  
  var githubView: some View {
    VStack {
      HStack(alignment: .top) {
        VStack(alignment: .leading) {
          Text("weg-li ist open source")
            .font(.system(.headline, design: .monospaced))
            .foregroundColor(.white)
            .padding(.bottom, .grid(1))
          VStack(alignment: .leading) {
            Text("Dir fehlt ein feature oder du willst einen bug fixen?")
              .font(.system(.body, design: .monospaced))
              .foregroundColor(.gitHubBannerForeground)
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
        Text("Projekt anzeigen")
        Spacer()
        Image(systemName: "arrow.up.right")
      }
      .padding(.top, .grid(1))
      .font(.system(.body, design: .monospaced))
      .foregroundColor(.yellow)
    }
    .padding([.top, .bottom], .grid(1))
    .background(
      Color.gitHubBannerBackground
        .padding(-20)
    )
  }
  
  var versionNumberView: some View {
    Text("Version: \(Bundle.main.versionNumber).\(Bundle.main.buildNumber)")
      .frame(maxWidth: .infinity)
      .font(.subheadline)
  }
  
  var linkIcon: some View {
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
