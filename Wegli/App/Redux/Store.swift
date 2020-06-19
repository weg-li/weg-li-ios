//
//  Store.swift
//  Wegli
//
//  Created by Malte Bünz on 08.06.20.
//  Copyright © 2020 Stefan Trauth. All rights reserved.
//

import Combine
import Foundation

typealias AppStore = Store<AppState, AppAction, EnvironmentContainer>

final class Store<State, Action, Environment>: ObservableObject {
    @Published private(set) var state: State
    
    private let environment: Environment
    private let reducer: Reducer<State, Action, Environment>
    private var effectCancellables: Set<AnyCancellable> = []
    
    init(
        initialState: State,
        reducer: @escaping Reducer<State, Action, Environment>,
        environment: Environment
    ) {
        self.state = initialState
        self.reducer = reducer
        self.environment = environment
    }
    
    func send(_ action: Action) {
        guard let effect = reducer(&state, action, environment) else {
            return
        }
        return effect
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: send)
            .store(in: &effectCancellables)
    }
}

import SwiftUI

extension Store {
    func binding<LocalState>(
        get: @escaping (State) -> LocalState,
        send action: Action
    ) -> Binding<LocalState> {
        self.binding(get: get, send: { _ in action })
    }
    
    func binding<LocalState>(
        get: @escaping (State) -> LocalState,
        send localStateToViewAction: @escaping (LocalState) -> Action
    ) -> Binding<LocalState> {
        Binding(
            get: { get(self.state) },
            set: { newLocalState, transaction in
                withAnimation(transaction.disablesAnimations ? nil : transaction.animation) {
                    self.send(localStateToViewAction(newLocalState))
                }
        })
    }
}
