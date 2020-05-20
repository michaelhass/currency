//
//  ExchangeRate+Attributes.swift
//  Currency
//
//  Created by Michael Haß on 20.05.20.
//  Copyright © 2020 Michael Hass. All rights reserved.
//

import Foundation

extension ExchangeRateView {
    struct Attributes {

        private static let numberFormatter: NumberFormatter = {
            let numberFormatter = NumberFormatter()
            numberFormatter.minimumFractionDigits = 2
            numberFormatter.maximumFractionDigits = 2
            return numberFormatter
        }()

        let currencyState: CurrencyState?
        var showPicker: Bool = false

        // MARK: Computed properties

        var currencies: [CurrencyIdentifier] {
            currencyState?.currencies ?? []
        }

        var shouldUpdateCurrencies: Bool {
            // Refresh currencies after 60 minutes.
            let isExpired = currencyState?.quotesTimestamp?.isOlderThan(minutes: 60) ?? false
            return currencies.isEmpty || isExpired
        }

        var isCurrencySelectDisabled: Bool {
            currencyState.map(\.currencies.isEmpty) ?? false
        }

        var isSendDisabled: Bool {
            isCurrencySelectDisabled || currencyState?.selectedCurrency == nil
        }

        var message: String {
            switch currencyState?.requestState {
            case .fetching?:
                return "Updating data"
            case .error(let error):
                if case .errorResponse(let response)? = error as? CurrencyService.Error {
                    return response.info
                }
                return "Oh no, an error occured."
            default:
                return ""
            }
        }

        var selectedCurrency: CurrencyIdentifier? {
            currencyState?.selectedCurrency
        }

        var amount: Float? {
            currencyState?.amount
        }

        func numberString(for value: Float) -> String {
            Attributes.numberFormatter.string(from: .init(value: value)) ?? ""
        }

        var initialInputValue: String {
            currencyState
                .flatMap(\.amount)
                .map(numberString(for:))
                ?? ""
        }

        var results: [ExchangeResult] {
            currencyState?.result ?? []
        }

        var canCalculateResult: Bool {
            selectedCurrency != nil && amount != nil && !currencies.isEmpty
        }
    }
}
