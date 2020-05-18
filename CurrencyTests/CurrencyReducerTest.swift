//
//  CurrencyReducerTest.swift
//  CurrencyTests
//
//  Created by Michael Haß on 17.05.20.
//  Copyright © 2020 Michael Hass. All rights reserved.
//

import XCTest
@testable import Currency

class CurrencyReducerTest: XCTestCase {

    func testFetchAction() throws {
        let initialState = CurrencyState()
        let fetchAction = CurrencyActions.SetFetching(endoint: .currencyList)
        let updatedState = currencyReducer(state: initialState, action: fetchAction)

        // Request state should have changed
        XCTAssertTrue(updatedState.requestState == .some(.fetching(.currencyList)))
        // Everything else should equal initial state
        XCTAssertTrue(updatedState.currencies == initialState.currencies)
        XCTAssertTrue(updatedState.currencyQuotes == initialState.currencyQuotes)
    }

    func testErrorAction() throws {
        let initialState = CurrencyState()
        let errorAction = CurrencyActions.ShowError(error: Error())
        let updatedState = currencyReducer(state: initialState, action: errorAction)

        // Request state should have changed
        XCTAssertTrue(updatedState.requestState == .some(.error(Error())))
        // Everything else should equal initial state
        XCTAssertTrue(updatedState.currencies == initialState.currencies)
        XCTAssertTrue(updatedState.currencyQuotes == initialState.currencyQuotes)
    }

    func testSetCurrenciesAction() throws {
        let initialState = CurrencyState()
        let currencies: [String: String] = ["ABR3": "3", "ABR1": "1", "ABR2": "2"]
        let currencyList: CurrencyList = .init(currencies: currencies)
        let setCurrenciesAction = CurrencyActions.SetCurrencies(endpoint: .currencyList, list: currencyList)
        let updatedState = currencyReducer(state: initialState, action: setCurrenciesAction)

        XCTAssertTrue(updatedState.requestState == .some(.success(setCurrenciesAction.endpoint)))
        let sortedCurrencies = updatedState.currencies.map(\.abbr)
        let expectationSorted = ["ABR1", "ABR2", "ABR3"]
        XCTAssertTrue(sortedCurrencies == expectationSorted)
        XCTAssertTrue(updatedState.currencyQuotes == initialState.currencyQuotes)
    }

    func testSetLiveQuotesAction() throws {
        let initialState = CurrencyState()
        let source = "USD"
        let quotes: [String: Float] = ["USDJPY": 1000]
        let currencyQuotes: CurrencyQuotes = .init(source: source, timestamp: .pi, quotes: quotes)
        let liveQuotesAction = CurrencyActions.SetLiveQuotes(endpoint: .liveQuotes,
                                                             quotes: currencyQuotes,
                                                             timestamp: 100)

        let updatedState = currencyReducer(state: initialState, action: liveQuotesAction)

        XCTAssertTrue(updatedState.requestState == .some(.success(liveQuotesAction.endpoint)))
        XCTAssertTrue(updatedState.currencyQuotes == currencyQuotes)
        XCTAssertTrue(updatedState.quotesTimestamp == 100)
        XCTAssertTrue(updatedState.currencies == initialState.currencies)
    }

    func testSetAmountAction() {
        let initialState = CurrencyState()
        let amountAction = CurrencyActions.SetAmount(amount: 111)
        let updatedState = currencyReducer(state: initialState, action: amountAction)

        XCTAssertTrue(updatedState.amount == amountAction.amount)
        XCTAssertTrue(updatedState.requestState == initialState.requestState)
    }

    func testSetSelectedCurrency() {
        let initialState = CurrencyState()
        let selectAction = CurrencyActions.SetSelectedCurrency(currency: .init(abbr: "ABC", name: "A B C"))
        let updatedState = currencyReducer(state: initialState, action: selectAction)

        XCTAssertTrue(updatedState.selectedCurrency == selectAction.currency)
        XCTAssertTrue(updatedState.requestState == initialState.requestState)
    }

    func testUpdateRatesAction() {
        let now = Date().timeIntervalSince1970
        let quotesDict: [String: Float] = ["EURUSD": 0.9, "EURJPY": 1000, "EUREUR": 1]
        let quotes = CurrencyQuotes(source: "EUR", timestamp: now, quotes: quotesDict)
        let amount: Float = 530
        let selectedCurrency = CurrencyIdentifier(abbr: "JPY", name: "Yen")
        let currencies: [CurrencyIdentifier] = [
            .init(abbr: "USD", name: "Dollar"),
            selectedCurrency,
            .init(abbr: "EUR", name: "EURO")
        ]

        let initialState = CurrencyState(
            requestState: .idle,
            currencyQuotes: quotes,
            quotesTimestamp: now,
            currencies: currencies,
            selectedCurrency: selectedCurrency,
            amount: amount, result: []
        )

        let updatedState = currencyReducer(state: initialState, action: CurrencyActions.UpdateRates())

        XCTAssertFalse(updatedState.result.isEmpty)

        // Check result orrder
        let resultAbbr = updatedState.result.map(\.id) // id equals abbr
        let currenciesAbbr = initialState.currencies.map(\.id)
        let orderError = "Order of results should match the order of the initial currency list"
        XCTAssertTrue(resultAbbr == currenciesAbbr, orderError)

        let calculateExchangeRate = { (amount: Float, selectedRate: Float, targetRate: Float) -> Float in
            return (1.0 / selectedRate) * targetRate * amount
        }

        // TEST: JPY -> USD
        if let result = updatedState.result.first(where: { $0.id == "USD"}) {
            XCTAssertTrue(result.exchangeAmount == calculateExchangeRate(amount, 1000, 0.9))
        } else {
            XCTFail("Could not find result for USD")
        }

        // TEST: JPY -> EUR
        if let result = updatedState.result.first(where: { $0.id == "EUR"}) {
            XCTAssertTrue(result.exchangeAmount == calculateExchangeRate(amount, 1000, 1))
        } else {
            XCTFail("Could not find result for JPY")
        }

        // TEST: JPY -> JPY
        if let result = updatedState.result.first(where: { $0.id == "JPY"}) {
            XCTAssertTrue(result.exchangeAmount == amount)
        } else {
            XCTFail("Could not find result for JPY")
        }
    }
}

extension CurrencyReducerTest {
    private struct Error: Swift.Error {}
}
