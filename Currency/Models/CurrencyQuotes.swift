//
//  CurrencyRates.swift
//  Currency
//
//  Created by Michael Haß on 17.05.20.
//  Copyright © 2020 Michael Hass. All rights reserved.
//

import Foundation

struct CurrencyQuotes: Codable {
    let source: String
    let timestamp: TimeInterval
    let quotes: [String: String]
}
