//
//  AppStateMiddleWares.swift
//  Currency
//
//  Created by Michael Haß on 18.05.20.
//  Copyright © 2020 Michael Hass. All rights reserved.
//

import Foundation

func createLoggerMiddleware() -> Middleware<AppState> {
    return { dispatch, state in
        return { action in
            dispatch(action)
            #if DEBUG
            print("[LOG] - \(Date())")
            print("[LOG] - performed action: \(action)")
            print("[LOG] - current state: \(state())")
            print()
            #endif
        }
    }
}

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
