import SettingsFeature
import SwiftUI

struct ContentView: View {
  var body: some View {
    SettingsView(
      store: .init(
        initialState: .init(
          accountSettingsState: .init(accountSettings: .init(apiToken: "")),
          contact: .empty,
          userSettings: .init()
        ),
        reducer: settingsReducer,
        environment: .init(
          uiApplicationClient: .live,
          keychainClient: .live(),
          mainQueue: .main
        )
      )
    )
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
