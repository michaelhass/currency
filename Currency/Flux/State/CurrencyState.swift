//
//  CurrencyState.swift
//  Currency
//
//  Created by Michael Haß on 17.05.20.
//  Copyright © 2020 Michael Hass. All rights reserved.
//

import Foundation

struct CurrencyState {
    var currencyList: CurrencyList?
    var requestState: RequestState = .idle
    var currencyRates: CurrencyRates?

    enum RequestState {
        case idle
        case fetching(CurrencyService.Endpoint)
        case error(Swift.Error)
        case success(CurrencyService.Endpoint)
    }
}
