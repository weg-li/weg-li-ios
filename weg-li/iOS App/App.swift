// Created for weg-li in 2021.

import AppFeature
import ComposableArchitecture
import CoreLocation
import SwiftUI
import UIKit

@main
struct WegliApp: App {
  var body: some Scene {
    WindowGroup {
      AppView(
        store: Store(
          initialState: AppState(),
          reducer: appReducer,
          environment: AppEnvironment(
            mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
            userDefaultsClient: .live()
          )
        )
      )
    }
  }
}
