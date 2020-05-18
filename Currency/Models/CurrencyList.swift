//
//  CurrencyList.swift
//  Currency
//
//  Created by Michael Haß on 17.05.20.
//  Copyright © 2020 Michael Hass. All rights reserved.
//

import Foundation

struct CurrencyList: Codable, Equatable, CustomStringConvertible {
    let currencies: [String: String]

    var description: String {
        return "currencies: \(currencies.shortDescriptor(maxElements: 3))"
    }
}

struct CurrencyIdentifier: Codable, Equatable, Identifiable {
    var id: String { abbr }
    let abbr: String
    let name: String
}
