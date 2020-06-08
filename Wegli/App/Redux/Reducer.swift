//
//  Reducer.swift
//  Wegli
//
//  Created by Malte Bünz on 08.06.20.
//  Copyright © 2020 Stefan Trauth. All rights reserved.
//

import Combine
import Foundation

func appReducer(
    state: inout AppState,
    action: AppAction,
    environment: EnvironmentContainer
) -> AnyPublisher<AppAction, Never> {
    switch action {
    case let .setContact(contact):
        state.contact = contact
        environment.personalDataRepository.contact = contact
    case let .addImage(image):
        environment.dataStore.add(image: image)
        state.report.images = environment.dataStore.images
    }
    return Empty().eraseToAnyPublisher()
}

typealias Reducer<State, Action, Environment> =
    (inout State, Action, Environment) -> AnyPublisher<Action, Never>?
