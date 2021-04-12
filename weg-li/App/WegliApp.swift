// Created for weg-li in 2021.

import ComposableArchitecture
import CoreLocation
import SwiftUI
import UIKit

@main
struct WegliApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView(
                store: Store(
                    initialState: HomeState(),
                    reducer: homeReducer,
                    environment: HomeEnvironment(
                        mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
                        userDefaultsClient: .live(),
                        imageConverter: .live()
                    )
                )
            )
        }
    }
}
