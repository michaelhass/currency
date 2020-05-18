//
//  CurrencyState.swift
//  Currency
//
//  Created by Michael Haß on 17.05.20.
//  Copyright © 2020 Michael Hass. All rights reserved.
//

import Foundation

struct CurrencyState: Equatable, Codable {
    var requestState: RequestState = .idle
    var currencyQuotes: CurrencyQuotes?
    var quotesTimestamp: TimeInterval?
    var currencies: [CurrencyIdentifier] = []
    var selectedCurrency: CurrencyIdentifier?
    var amount: Float?
    var result: [ExchangeResult] = []

    enum CodingKeys: String, CodingKey {
        case currencyQuotes
        case quotesTimestamp
        case currencies
        case selectedCurrency
        case amount
        case result
    }
}

extension CurrencyState {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        currencyQuotes = try container.decodeIfPresent(CurrencyQuotes.self, forKey: .currencyQuotes)
        quotesTimestamp = try container.decodeIfPresent(TimeInterval.self, forKey: .quotesTimestamp)
        currencies = (try container.decodeIfPresent([CurrencyIdentifier].self, forKey: .currencies)) ?? []
        selectedCurrency = try container.decodeIfPresent(CurrencyIdentifier.self, forKey: .selectedCurrency)
        // ignoe the other properties
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(currencyQuotes, forKey: .currencyQuotes)
        try container.encodeIfPresent(quotesTimestamp, forKey: .quotesTimestamp)
        try container.encode(currencies, forKey: .currencies)
        try container.encodeIfPresent(selectedCurrency, forKey: .selectedCurrency)
    }
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
