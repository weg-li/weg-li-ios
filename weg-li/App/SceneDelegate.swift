//
//  SceneDelegate.swift
//  weg-li
//
//  Created by Stefan Trauth on 08.10.19.
//  Copyright © 2019 Stefan Trauth. All rights reserved.
//

import CoreLocation
import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        let contentView = MainView()
            .environmentObject(generateAppStore())
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)
            self.window = window
            window.makeKeyAndVisible()
        }
    }
    
    private func generateAppStore() -> AppStore {
        let environment = EnvironmentContainer(
            personalDataRepository: PersonsalDataRepository(),
            dataStore: ReportImageDataStore(),
            locationProvider: LocationProvider(),
            geoCoder: GeoCodeProvider(),
            exifReader: ExifReader(),
            officeMatcher: PublicAffairsOfficeMatcher()
        )
        let state = AppState(
            contact: environment.personalDataRepository.contact,
            report: Report(images: environment.dataStore.images),
            location: AppState.LocationState.init(location: .zero, presumedAddress: nil))
        return AppStore(initialState: state, reducer: appReducer, environment: environment)
    }
}

