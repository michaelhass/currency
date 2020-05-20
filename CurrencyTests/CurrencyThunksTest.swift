//
//  CurrencyThunksTest.swift
//  CurrencyTests
//
//  Created by Michael Haß on 17.05.20.
//  Copyright © 2020 Michael Hass. All rights reserved.
//

import XCTest
@testable import Currency

class CurrencyThunksTest: XCTestCase {

    private let baseURL = URL(string: "https://duckduckgo.com/")!
    // Always create a new instance
    var store: Store<AppState> = CurrencyThunksTest.createStore()

    private static func createStore() -> Store<AppState> {
        .init(initialState: .initial,
              reducer: appReducer(state:action:),
              middleware: [createThunkMiddleware()])
    }

    override func tearDownWithError() throws {
        CurrencyServiceMocking.setTestData(testData: [:], baseURL: baseURL)
        store = CurrencyThunksTest.createStore()
    }

    func testRequestCurrenciesError() throws {
        let testData: [CurrencyService.Endpoint: String] = [
            .currencyList: "error_response"
        ]

        let service = CurrencyService.testing(baseURL: baseURL, testData: testData)
        let thunk: Thunk<AppState> = CurrencyActions.requestCurrencies(service: service)

        testError(thunk: thunk, endpoint: .currencyList, testData: testData)
    }

    func testRequestCurrenciesSuccess() throws {
        let testData: [CurrencyService.Endpoint: String] = [
            .currencyList: "currencies"
        ]

        let service = CurrencyService.testing(baseURL: baseURL, testData: testData)
        let thunk: Thunk<AppState> = CurrencyActions.requestCurrencies(service: service)

        testSuccess(thunk: thunk, endpoint: .currencyList, testData: testData)
    }

    func testRequestLiveQuotesError() throws {
        let testData: [CurrencyService.Endpoint: String] = [
            .liveQuotes: "error_response"
        ]

        let service = CurrencyService.testing(baseURL: baseURL, testData: testData)
        let thunk: Thunk<AppState> = CurrencyActions.requestRates(service: service)

        testError(thunk: thunk, endpoint: .liveQuotes, testData: testData)
    }

    func testRequestLiveQuotesSuccess() throws {
        let testData: [CurrencyService.Endpoint: String] = [
            .liveQuotes: "usd_quotes"
        ]

        let service = CurrencyService.testing(baseURL: baseURL, testData: testData)
        let thunk: Thunk<AppState> = CurrencyActions.requestRates(service: service)

        testSuccess(thunk: thunk, endpoint: .liveQuotes, testData: testData)
    }

    // MARK: Helper

    func testError(thunk: Thunk<AppState>,
                   endpoint: CurrencyService.Endpoint,
                   testData: [CurrencyService.Endpoint: String]) {

        let expectFetching = XCTestExpectation(description: "Expect to be fetching: \(endpoint)")
        let expectError = XCTestExpectation(description: "Expect to have an error for request: \(endpoint)")

        _ = store.$state
            .subscribe(on: DispatchQueue.main)
            .compactMap { $0?.currencyState }
            .sink(receiveValue: { currencyState in
                switch currencyState.requestState {
                case .fetching(let value) where value == endpoint:
                    expectFetching.fulfill()
                case .error:
                    expectError.fulfill()
                default: break
                }
            })

        store.dispatch(action: thunk)
        wait(for: [expectFetching, expectError], timeout: 5)
    }

    func testSuccess(thunk: Thunk<AppState>,
                     endpoint: CurrencyService.Endpoint,
                     testData: [CurrencyService.Endpoint: String]) {

        let expectFetching = XCTestExpectation(description: "Expect to be fetching: \(endpoint)")
        let expectSuccess = XCTestExpectation(description: "Expect success for request: \(endpoint)")

        _ = store.$state
            .subscribe(on: DispatchQueue.main)
            .compactMap { $0?.currencyState }
            .sink(receiveValue: { currencyState in
                switch currencyState.requestState {
                case .fetching(let value) where value == endpoint:
                    expectFetching.fulfill()
                case .success(let value) where value == endpoint:
                    expectSuccess.fulfill()
                default: break
                }
            })

        store.dispatch(action: thunk)
        wait(for: [expectFetching, expectSuccess], timeout: 5)
    }
}
