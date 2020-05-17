//
//  Shared.swift
//  Currency
//
//  Created by Michael Haß on 17.05.20.
//  Copyright © 2020 Michael Hass. All rights reserved.
//

import Foundation

struct Shared {
    let currencyService: CurrencyService
}

struct TestData {
    let currencyService: [CurrencyService.Endpoint: String]
}

extension Shared {

    static func `default`(baseURL: URL, apiKey: String) -> Shared {
        let currencyService = CurrencyService(baseURL: baseURL, apiKey: apiKey, session: .shared)
        return .init(currencyService: currencyService)
    }

    static func testing(baseURL: URL, testData: TestData) -> Shared {
        CurrencyServiceMocking.setTestData(testData: testData.currencyService, baseURL: baseURL)
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [CurrencyServiceMocking.self]
        let session = URLSession(configuration: config)
        let currencyService = CurrencyService(baseURL: baseURL, apiKey: "TEST_KEY", session: session)
        return .init(currencyService: currencyService)
    }
}
