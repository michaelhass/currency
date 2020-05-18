//
//  AppStateMiddleWares.swift
//  Currency
//
//  Created by Michael Haß on 18.05.20.
//  Copyright © 2020 Michael Hass. All rights reserved.
//

import Foundation

/// Creates a middleware that logs the current state
/// after exectuting the dispatch function.
/// NOTE: Logs only in debug mode.
func createLoggerMiddleware() -> Middleware<AppState> {
    return { dispatch, state in
        return { action in
            dispatch(action)
            #if DEBUG
            print("[LOG] - \(Date())")
            print("[LOG] - performed action:")
            print("[LOG] - \(action)")
            print("[LOG]")
            print("[LOG] - current state:")
            print("[LOG] - \(state())")
            print("[LOG]")
            print("[LOG] -------")
            print()
            #endif
        }
    }
}

/// Creates a middleware for handling ThunkActions.
/// NOTE: A Thunk may alter the dispatched action,
/// thus it should be the first middleware to perform any actions.
///
/// - Returns: a Middleware<AppState>
func createThunkMiddleware() -> Middleware<AppState> {
    return { dispatch, state in
        return { action in
            if let thunk = action as? Thunk<AppState> {
                thunk.body(dispatch, state)
            } else {
                dispatch(action)
            }
        }
    }
}

/// Creates a middleware that stores the current appstate
/// NOTE: Should be the last middleware to perform any actions
///
/// - Parameter cache: Cache to store data in
/// - Returns: a Middleware<AppState>
func createCacheMiddleware(cache: AppStateCache) -> Middleware<AppState> {
    return { dispatch, state in
        return { action in
            dispatch(action)
            do {
                try cache.store(state())
            } catch {
                #if DEBUG
                    print(error)
                #endif
            }

        }
    }
}
