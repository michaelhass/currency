//
//  AppState.swift
//  Currency
//
//  Created by Michael Haß on 17.05.20.
//  Copyright © 2020 Michael Hass. All rights reserved.
//

import Foundation

struct AppState: Equatable {
    var currencyState: CurrencyState

    static var initial: AppState {
        .init(currencyState: .init())
    }
}
