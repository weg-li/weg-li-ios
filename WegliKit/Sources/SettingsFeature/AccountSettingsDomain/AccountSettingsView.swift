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
            .clearButton(
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

struct ClearButton: ViewModifier {
  @Binding var text: String
  
  func body(content: Content) -> some View {
    ZStack(alignment: .trailing) {
      content
      
      if !text.isEmpty {
        Button {
          text = ""
        } label: {
          Image(systemName: "multiply.circle.fill")
            .foregroundStyle(.gray)
        }
        .padding(.trailing, 8)
      }
    }
  }
}
extension View {
  func clearButton(text: Binding<String>) -> some View {
    modifier(ClearButton(text: text))
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
