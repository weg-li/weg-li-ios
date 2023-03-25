// Created for weg-li in 2021.

import AppFeature
import ComposableArchitecture
import CoreLocation
import Styleguide
import SwiftUI
import UIKit

@main
struct WegliApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
  @Environment(\.scenePhase) var scenePhase
  
  init() {
    Styleguide.registerFonts()
  }
  
  var body: some Scene {
    WindowGroup {
      AppView(store: self.appDelegate.store)
        .onChange(of: scenePhase) { _ in }
    }
  }
}

// MARK: AppDelegate

final class AppDelegate: NSObject, UIApplicationDelegate {
  let store = Store(
    initialState: .init(),
    reducer: AppDomain()
  )
  lazy var viewStore = ViewStore(self.store.scope(state: { _ in () }))
  
  func application(
    _ application: UIApplication,
    // swiftlint:disable:next discouraged_optional_collection
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
  ) -> Bool {
    viewStore.send(.internalAction(.appDelegate(.didFinishLaunching)))
    return true
  }
}
