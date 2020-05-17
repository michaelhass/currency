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
}

extension CurrencyReducerTest {
    private struct Error: Swift.Error {}
}
