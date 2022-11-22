import ComposableArchitecture
import Foundation
import SharedModels
import Styleguide
import SwiftUI

// MARK: - View

public struct AccountSettingsView: View {
  public typealias S = AccountSettingsDomain.State
  public typealias A = AccountSettingsDomain.Action
  
  let store: Store<S, A>
  @ObservedObject var viewStore: ViewStore<S, A>
  
  public init(store: Store<S, A>) {
    self.store = store
    self.viewStore = ViewStore(store)
  }
  
  let description: AttributedString? = try? AttributedString(markdown: "Füge Deinen API-Token hinzu um die App mit deinem bestehenden Account zu verknüpfen und Anzeigen über [weg.li](https://www.weg.li) zu versenden. Du findest den API-Token in deinem Profil")
  
  public var body: some View {
    Form {
      Section(header: Label("API-Token", systemImage: "key.fill")) {
        VStack(alignment: .leading) {
          VStack(alignment: .leading, spacing: .grid(3)) {
            TextField(
              "",
              text: viewStore.binding(
                get: \.accountSettings.apiToken,
                send: A.setApiToken
              )
            )
            .placeholder(when: viewStore.state.accountSettings.apiToken.isEmpty, placeholder: {
              Text("API-Token")
                .italic()
                .foregroundColor(Color(.lightGray))
            })
            .lineLimit(1)
            .font(.body.monospaced())
            .keyboardType(.default)
            .foregroundColor(.white)
            .padding(.grid(3))
            .background(Color.gitHubBannerBackground)
            .accentColor(Color.green)
            .clipShape(RoundedRectangle(
              cornerRadius: .grid(2), style: .circular
            )
            )
            .overlay(
              RoundedRectangle(cornerRadius: .grid(2))
                .stroke(Color(.label), lineWidth: 2)
            )
            .disableAutocorrection(true)
            .submitLabel(.done)
            .padding(.vertical, .grid(4))
            
            HStack(alignment: .center) {}
              .padding(.vertical, .grid(2))
            
            VStack(alignment: .leading) {
              Text(description!)
                .multilineTextAlignment(.leading)
                .foregroundColor(Color(.secondaryLabel))
                .font(.subheadline)
                .padding(.vertical, .grid(1))
              
              Button(
                action: { viewStore.send(.openUserSettings) },
                label: {
                  Label("Profil öffnen", systemImage: "arrow.up.right")
                    .frame(maxWidth: .infinity, minHeight: 40)
                }
              )
              .buttonStyle(.bordered)
              .accessibilityAddTraits([.isLink])
              
              VStack(alignment: .center, spacing: .grid(2)) {
                Text("Die App supported aktuell folgende Operationen")
                  .multilineTextAlignment(.leading)
                
                VStack(alignment: .leading, spacing: .grid(1)) {
                  HStack {
                    Text("Meldungen abrufen")
                    Image(systemName: "checkmark.circle")
                  }
                  HStack {
                    Text("Meldungen hochladen/anlegen")
                    Image(systemName: "checkmark.circle")
                  }
                  HStack {
                    Text("Meldungen versenden")
                    Image(systemName: "x.circle")
                  }
                }
                
                Text("Um deine Meldung zu versenden musst du aktuell noch die Webseite nutzen")
                  .multilineTextAlignment(.leading)
                  .fixedSize(horizontal: false, vertical: true)
              }
              .padding(.top, .grid(2))
              .foregroundColor(Color(.secondaryLabel))
              .font(.footnote)
            }
            .padding(.grid(2))
            .overlay(
              RoundedRectangle(cornerRadius: 4)
                .stroke(Color(.lightGray), lineWidth: 1)
            )
          }
        }
      }
      .headerProminence(.increased)
    }
    .navigationBarTitle("Account", displayMode: .inline)
  }
}

private extension View {
  func placeholder<Content: View>(
    when shouldShow: Bool,
    alignment: Alignment = .leading,
    @ViewBuilder placeholder: () -> Content
  ) -> some View {
    ZStack(alignment: alignment) {
      placeholder().opacity(shouldShow ? 1 : 0)
      self
    }
  }
}

// MARK: Preview

struct AccountSettingsView_Previews: PreviewProvider {
  static var previews: some View {
    AccountSettingsView(
      store: .init(
        initialState: .init(accountSettings: .init(apiToken: "")),
        reducer: AccountSettingsDomain()
      )
    )
  }
}
