//
//  ExchangeResult.swift
//  Currency
//
//  Created by Michael Haß on 18.05.20.
//  Copyright © 2020 Michael Hass. All rights reserved.
//

import Foundation

struct ExchangeResult: Equatable, Identifiable {
    var id: String { currency.id }
    let currency: CurrencyIdentifier
    let exchangeAmount: Float
}
