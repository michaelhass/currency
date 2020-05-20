//
//  ExchangeRateView+Observer.swift
//  Currency
//
//  Created by Michael Haß on 20.05.20.
//  Copyright © 2020 Michael Hass. All rights reserved.
//

import Foundation

extension ExchangeRateView {

    struct Observer: InputFormObserver {
        private let dispatch: DispatchFunction
        private let selectedCurrency: CurrencyIdentifier?

        init(dispatch: @escaping DispatchFunction,
             selectedCurrency: CurrencyIdentifier?) {
            self.selectedCurrency = selectedCurrency
            self.dispatch = dispatch
        }

        func editingStarted() {
            // Do nothing
        }

        func editingEnded(text: String) {
            requestRates(amountText: text)
        }

        func editingCanceled() {
            // Do nothing
        }

        func textChanged(text: String) {
            requestRates(amountText: text)
        }

        private func requestRates(amountText: String) {
            Float(amountText)
                .map(CurrencyActions.SetAmount.init(amount:))
                .map(dispatch)

            shared
                .map(\.currencyService)
                .map { CurrencyActions.requestRates(service: $0) }
                .map(dispatch)
        }
    }

}
