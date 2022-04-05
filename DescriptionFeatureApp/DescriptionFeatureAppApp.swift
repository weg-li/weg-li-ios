import SwiftUI
import DescriptionFeature

@main
struct DescriptionFeatureAppApp: App {
    var body: some Scene {
        WindowGroup {
          EditDescriptionView(
            store: .init(
              initialState: .init(),
              reducer: descriptionReducer,
              environment: DescriptionEnvironment()
            )
          )
        }
    }
}
