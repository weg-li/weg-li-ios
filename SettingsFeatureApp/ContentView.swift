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
        reducer: SettingsDomain()
      )
    )
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
