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
    case let .handleLocationAction(locationAction):
        switch locationAction {
        case .onLocationAppear:
            return Just(AppAction.handleLocationAction(.requestPermission))
                .eraseToAnyPublisher()
        case .requestPermission:
            return Future<Int, Never> { promise in
                environment.locationProvider.requestPermission()
                return promise(.success(1))
            }
            .delay(for: 3.0, scheduler: RunLoop.main)
            .receive(on: RunLoop.main)
            .map {_ in AppAction.handleLocationAction(.requestLocation) }
            .eraseToAnyPublisher()
        case .requestLocation:
            environment.locationProvider.requestLocation()
            return environment.locationProvider
                .location
                .removeDuplicates()
                .replaceError(with: CLLocation(latitude: 0, longitude: 0))
                .map { AppAction.handleLocationAction(.setLocation($0.coordinate)) }
                .eraseToAnyPublisher()
        case let .resolveAddress(option):
            switch option {
            case .currentLocation:
                break
            case .fromPhotos:
                environment.exifReader.readLocationMetaData(from: state.report.images)
            case .manual:
                print("👨‍🏭")
            }
        case let .setUserDefinedLocation(coordinate):
            state.location.userDefinedLocation = coordinate
        case let .setLocation(location):
            state.location.location = location
            return environment.geoCoder
                .getPlacemarks(for: CLLocation(latitude: location.latitude, longitude: location.longitude))
                .replaceError(with: [])
                .map { AppAction.handleLocationAction(.setResolvedAddress($0.first)) }
                .eraseToAnyPublisher()
        case let .setResolvedAddress(address):
            guard state.location.presumedAddress != address else { break }
            state.location.presumedAddress = address
        }
        
    case let .setContact(contact):
        state.contact = contact
        environment.personalDataRepository.contact = contact
    case let .addImage(image):
        environment.dataStore.add(image: image)
        state.report.images = environment.dataStore.images
    case .handleDescriptionAction(let descriptionAction):
        switch descriptionAction {
        case let .setCar(car):
            state.report.car = car
        case let .setCharge(crime):
            state.report.charge = crime
        }
    case .none:
        break
    }
    return Empty().eraseToAnyPublisher()
}

typealias Reducer<State, Action, Environment> =
    (inout State, Action, Environment) -> AnyPublisher<Action, Never>?
