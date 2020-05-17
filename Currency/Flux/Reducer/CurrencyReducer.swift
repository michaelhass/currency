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

    case let setCurrencies as CurrencyActions.SetCurrencies:
        state.requestState = .success(setCurrencies.endpoint)
        state.currencies = setCurrencies.list.currencies
            .map { element in
                .init(abbr: element.key, name: element.value)
            }.sorted { (lhs, rhs) in
                lhs.abbr < rhs.abbr
            }
    case let setLiveQuotes as CurrencyActions.SetLiveQuotes:
        state.requestState = .success(setLiveQuotes.endpoint)
        state.currencyQuotes = setLiveQuotes.quotes
        state.quotesTimestamp = setLiveQuotes.timestamp

    case let setAmout as CurrencyActions.SetAmount:
        state.amount = setAmout.amount

    case let selectedCurrency as CurrencyActions.SetSelectedCurrency:
        state.selectedCurrency = selectedCurrency.currency

    case is CurrencyActions.UpdateRates:
        guard let selectedCurrency = state.selectedCurrency else { break }
        guard let selectedAmount = state.amount else { break }
        guard let quotes = state.currencyQuotes else { break }

        let sourceCurrency = quotes.source
        let selectedKey = sourceCurrency + selectedCurrency.abbr

        state.result = quotes.quotes[selectedKey].map { sourceToSelectedRate in
             state.currencies.compactMap { targetCurrency in
                let targetKey = sourceCurrency + targetCurrency.abbr
                guard let sourceToTargetRate = quotes.quotes[targetKey] else { return nil }

                let exchangeAmount: Float = (1.0 / sourceToSelectedRate)
                    * sourceToTargetRate
                    * selectedAmount

                return .init(currency: targetCurrency, exchangeAmount: exchangeAmount)
            }
        } ?? []

    default:
        break
    }
    return state
}
