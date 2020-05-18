//
//  FluxCoreTypes.swift
//  Currency
//
//  Created by Michael Haß on 16.05.20.
//  Copyright © 2020 Michael Hass. All rights reserved.
//

import Foundation

/// Marker protocol for actions / events that occure
/// during application runtime
protocol Action { }

/// An action that may perform side effects and dispatch other actions.
struct Thunk<State>: Action {
    let body: (_ dispatch: @escaping DispatchFunction, _ state: @escaping () -> State) -> Void
}

/// A handler for executing side effects when dispatching actions.
typealias Middleware<State> = (_ dispatch: @escaping DispatchFunction, _ state: @escaping () -> State)
    -> DispatchFunction

/// Only place where state updates should occure.
typealias Reducer<State> = (_ state: State, _ action: Action) -> State

/// Function to dispatch actions on
typealias DispatchFunction = (_ action: Action) -> Void

/// Place where your Application State is stored. Accepts actions and passes them to the reducers.
final class Store<State>: ObservableObject {

    @Published private(set) var state: State
    private let reducer: Reducer<State>
    private let middleware: [Middleware<State>]

    /// Initializes a Store with the application's main state and reducer.
    ///
    /// - Parameters:
    ///   - initialState: The application's root state
    ///   - reducer: The root reducer to use
    init(initialState: State,
         reducer: @escaping Reducer<State>,
         middleware: [Middleware<State>]) {

        self.state = initialState
        self.reducer = reducer
        self.middleware = middleware
    }

    /// Passes the given action to the correct reducer.
    /// Code will be executed on main thread because state updates directly
    /// trigger view updates -> @published.
    ///
    /// - Parameter action: Action to perform
    func dispatch(action: Action) {
        DispatchQueue.main.async { [weak self] in
            self?.dispatchFunction(action)
        }
    }

    private lazy var dispatchFunction: DispatchFunction = {
        let defaultDispatch: DispatchFunction = { [weak self] action in
            guard let self = self else { return }
            self.state = self.reducer(self.state, action)
        }

        return middleware
            .reversed()
            .reduce(defaultDispatch) { (dispatch, middleWare) in
                middleWare(dispatch, { self.state })
        }
    }()
}
