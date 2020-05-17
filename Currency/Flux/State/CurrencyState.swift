//
//  CurrencyState.swift
//  Currency
//
//  Created by Michael Haß on 17.05.20.
//  Copyright © 2020 Michael Hass. All rights reserved.
//

import Foundation

struct CurrencyState: Equatable {

    var requestState: RequestState = .idle
    var currencyQuotes: CurrencyQuotes?
    var currencies: [CurrencyIdentifier] = []
    var selectedCurrency: CurrencyIdentifier?
    var amount: Float?
}

extension CurrencyState {

    enum RequestState: Equatable {

        case idle
        case fetching(CurrencyService.Endpoint)
        case error(Swift.Error)
        case success(CurrencyService.Endpoint)

        static func == (lhs: RequestState, rhs: RequestState) -> Bool {
            switch (lhs, rhs) {
            case (.idle, .idle):
                return true
            case (.fetching(let lhsEndpoint), .fetching(let rhsEndpoint)):
                return lhsEndpoint == rhsEndpoint
            case (.success(let lhsEndpoint), .success(let rhsEndpoint)):
                return lhsEndpoint == rhsEndpoint
            case (.error, .error):
                // Ignore actual error
                return true
            default:
                return false
            }
        }

    }
}
