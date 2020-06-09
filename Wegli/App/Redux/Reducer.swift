//
//  Reducer.swift
//  Wegli
//
//  Created by Malte Bünz on 08.06.20.
//  Copyright © 2020 Stefan Trauth. All rights reserved.
//

import Combine
import CoreLocation
import Foundation

func appReducer(
    state: inout AppState,
    action: AppAction,
    environment: EnvironmentContainer
) -> AnyPublisher<AppAction, Never> {
    switch action {
    case let .resolveAddress(option):
        switch option {
        case .currentLocation:
            let publisher = environment.locationProvider
                .location
                .replaceError(with: CLLocation(latitude: 0, longitude: 0))
                .map { AppAction.setLocation($0.coordinate) }
                .eraseToAnyPublisher()
            environment.locationProvider.requestLocation()
            return publisher
        case .fromPhotos:
            environment.exifReader.readLocationMetaData(from: state.report.images)
        case .manual:
            print("👨‍🏭")
        }
    case let .setContact(contact):
        state.contact = contact
        environment.personalDataRepository.contact = contact
    case let .addImage(image):
        environment.dataStore.add(image: image)
        state.report.images = environment.dataStore.images
    case let .setLocation(location):
        state.location.location = location
        return environment.geoCoder
            .getPlacemarks(for: CLLocation(latitude: location.latitude, longitude: location.longitude))
            .replaceError(with: [])
            .map { AppAction.setResolvedAddress($0.first) }
            .eraseToAnyPublisher()
    case let .setResolvedAddress(address):
        print(address ?? "🏡")
        state.location.presumedAddress = address
    }
    return Empty().eraseToAnyPublisher()
}

typealias Reducer<State, Action, Environment> =
    (inout State, Action, Environment) -> AnyPublisher<Action, Never>?
