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
    let appStateCache: AppStateCache?
}

struct TestData {
    let currencyService: [CurrencyService.Endpoint: String]
}

// MARK: - Helper

extension Shared {

    static func `default`(baseURL: URL, apiKey: String) -> Shared {
        return .init(currencyService: .init(baseURL: baseURL, apiKey: apiKey, session: .shared),
                     appStateCache: try? .init(fileManager: .default))
    }

    static func testing(baseURL: URL, testData: TestData) -> Shared {
        return .init(currencyService: .testing(baseURL: baseURL, testData: testData.currencyService),
                     appStateCache: try? .init(fileManager: .default))
    }
}
