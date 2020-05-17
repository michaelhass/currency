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
        XCTAssertTrue(updatedState.currencyList == initialState.currencyList)
        XCTAssertTrue(updatedState.currencyQuotes == initialState.currencyQuotes)
    }

    func testErrorAction() throws {
        let initialState = CurrencyState()
        let errorAction = CurrencyActions.ShowError(error: Error())
        let updatedState = currencyReducer(state: initialState, action: errorAction)

        // Request state should have changed
        XCTAssertTrue(updatedState.requestState == .some(.error(Error())))
        // Everything else should equal initial state
        XCTAssertTrue(updatedState.currencyList == initialState.currencyList)
        XCTAssertTrue(updatedState.currencyQuotes == initialState.currencyQuotes)

    }

    func testSetCurrenciesAction() throws {
        let initialState = CurrencyState()
        let currencies: [String: String] = ["JPY": "Japanese Yen"]
        let currencyList: CurrencyList = .init(currencies: currencies)
        let setCurrenciesAction = CurrencyActions.SetCurrencies(endpoint: .currencyList, list: currencyList)
        let updatedState = currencyReducer(state: initialState, action: setCurrenciesAction)

        XCTAssertTrue(updatedState.requestState == .some(.success(setCurrenciesAction.endpoint)))
        XCTAssertTrue(updatedState.currencyList == currencyList)

        XCTAssertTrue(updatedState.currencyQuotes == initialState.currencyQuotes)
    }

    func testSetLiveQuotesAction() throws {
        let initialState = CurrencyState()
        let source = "USD"
        let quotes: [String: Float] = ["USDJPY": 1000]
        let currencyQuotes: CurrencyQuotes = .init(source: source, timestamp: .pi, quotes: quotes)
        let liveQuotesAction = CurrencyActions.SetLiveQuotes(endpoint: .liveQuotes, quotes: currencyQuotes)

        let updatedState = currencyReducer(state: initialState, action: liveQuotesAction)

        XCTAssertTrue(updatedState.requestState == .some(.success(liveQuotesAction.endpoint)))
        XCTAssertTrue(updatedState.currencyQuotes == currencyQuotes)

        XCTAssertTrue(updatedState.currencyList == initialState.currencyList)
    }
}

extension CurrencyReducerTest {
    private struct Error: Swift.Error {}
}
