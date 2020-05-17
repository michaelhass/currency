//
//  AppReducer.swift
//  Currency
//
//  Created by Michael Haß on 17.05.20.
//  Copyright © 2020 Michael Hass. All rights reserved.
//

import Foundation

func appReducer(state: AppState, action: Action) -> AppState {
    var state = state
    state.currencyState = currencyReducer(state: state.currencyState, action: action)
    return state
}
