import ComposableArchitecture
import SharedModels
import SettingsFeature
import SwiftUI

struct ContentView: View {
  var body: some View {
    SettingsView(
      store: Store(initialState: SettingsDomain.State(
        accountSettingsState: AccountSettingsDomain.State(
          accountSettings: AccountSettings(apiToken: "")
        ),
        userSettings: UserSettings())
      ) {
        SettingsDomain()
      }
    )
  }
}

#Preview {
  ContentView()
}
