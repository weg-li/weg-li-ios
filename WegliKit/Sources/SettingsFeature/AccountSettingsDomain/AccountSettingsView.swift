import ComposableArchitecture
import Foundation
import SafariServices
import SharedModels
import Styleguide
import SwiftUI

// MARK: - View

public struct AccountSettingsView: View {
  public typealias S = AccountSettingsDomain.State
  public typealias A = AccountSettingsDomain.Action
  
  let store: StoreOf<AccountSettingsDomain>
  @ObservedObject var viewStore: ViewStoreOf<AccountSettingsDomain>
  
  let userLink = URL(string: "https://www.weg.li/user")!
  
  public init(store: StoreOf<AccountSettingsDomain>) {
    self.store = store
    self.viewStore = ViewStore(store, observe: { $0 })
  }
  
  let description = "Füge Deinen API-Token hinzu um die App mit deinem bestehenden Account zu verknüpfen und Anzeigen über www.weg.li zu versenden. Du findest den API-Token in deinem Profil"
  
  public var body: some View {
    WithViewStore(store, observe: \.accountSettings) { viewStore in
      
    }
    List {
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
            .placeholder(
              when: viewStore.state.accountSettings.apiToken.isEmpty,
              placeholder: {
                Text("API-Token")
                  .italic()
                  .foregroundColor(Color(.lightGray))
              }
            )
            .onAppear { UITextField.appearance().clearButtonMode = .whileEditing }
            .lineLimit(1)
            .font(.body.monospaced())
            .keyboardType(.default)
            .padding(.grid(3))
            .clipShape(RoundedRectangle(cornerRadius: .grid(2), style: .circular))
            .overlay(
              RoundedRectangle(cornerRadius: .grid(2))
                .stroke(Color(.label), lineWidth: 2)
            )
            .disableAutocorrection(true)
            .submitLabel(.done)
            .padding(.vertical, .grid(4))
            
            VStack(alignment: .leading) {
              Text(description)
                .multilineTextAlignment(.leading)
                .foregroundColor(Color(.secondaryLabel))
                .font(.subheadline)
                .padding(.vertical, .grid(1))
              
              Button(
                action: { viewStore.send(.onGoToProfileButtonTapped) },
                label: {
                  Label("Profil öffnen", systemImage: "arrow.up.right")
                    .padding(.grid(1))
                    .frame(maxWidth: .infinity)
                }
              )
              .buttonStyle(CTAButtonStyle())
              .accessibilityAddTraits([.isLink])
              
              Text("Oder erstelle ein Profil")
                .multilineTextAlignment(.leading)
                .foregroundColor(Color(.secondaryLabel))
                .font(.subheadline)
                .padding(.vertical, .grid(1))
              
              Button(
                action: { viewStore.send(.onCreateProfileButtonTapped) },
                label: {
                  Label("Profil erstellen", systemImage: "arrow.up.right")
                    .padding(.grid(1))
                    .frame(maxWidth: .infinity)
                }
              )
              .frame(maxWidth: .infinity)
              .buttonStyle(CTAButtonStyle())
              .accessibilityAddTraits([.isLink])
            }
            .padding(.grid(2))
          }
        }
      }
      .headerProminence(.increased)
    }
    .sheet(unwrapping: viewStore.binding(get: \.link, send: A.dismissSheet), content: { url in
      SafariView(url: url.wrappedValue.url)
    })
    .navigationBarTitle("Account", displayMode: .automatic)
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

struct SafariView: UIViewControllerRepresentable {
  let url: URL
  
  func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
    return SFSafariViewController(url: url)
  }
  
  func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariView>) {
    
  }
}
