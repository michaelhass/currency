//
//  CurrencyRates.swift
//  Currency
//
//  Created by Michael Haß on 17.05.20.
//  Copyright © 2020 Michael Hass. All rights reserved.
//

import Foundation

struct CurrencyQuotes: Codable, Equatable {
    let source: String
    // Age of the currency quotes.
    // NOTE: Does not necessary equal requested time
    let timestamp: TimeInterval
    let quotes: [String: Float]
}
