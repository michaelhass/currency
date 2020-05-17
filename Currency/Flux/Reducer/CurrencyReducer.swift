//
//  CurrencyReducer.swift
//  Currency
//
//  Created by Michael Haß on 17.05.20.
//  Copyright © 2020 Michael Hass. All rights reserved.
//

import Foundation

func currencyReducer(state: CurrencyState, action: Action) -> CurrencyState {

    var state = state

    switch action {
    case let fetchAction as CurrencyActions.SetFetching:
        state.requestState = .fetching(fetchAction.endoint)
    case let errorAction as CurrencyActions.ShowError:
        state.requestState = .error(errorAction.error)
    case let successAction as CurrencyActions.SetCurrencies:
        state.requestState = .success(successAction.endpoint)
        state.currencies = successAction.list.currencies
            .map { element in
                .init(abbr: element.key, name: element.value)
            }.sorted { (lhs, rhs) in
                lhs.abbr < rhs.abbr
            }
    case let successAction as CurrencyActions.SetLiveQuotes:
        state.requestState = .success(successAction.endpoint)
        state.currencyQuotes = successAction.quotes
    default:
        break
    }
    return state
}
