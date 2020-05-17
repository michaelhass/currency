//
//  SceneDelegate.swift
//  Currency
//
//  Created by Michael Haß on 16.05.20.
//  Copyright © 2020 Michael Hass. All rights reserved.
//

import UIKit
import SwiftUI

private(set) var shared: Shared?

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private typealias StoreType = Store<AppState>
    private var store: StoreType?

    override init() {
        super.init()

        // NOTE: Free subscription plan does not support HTTPS
        let baseURL = URL(string: "http://api.currencylayer.com/")!
        // Place your api key here
        let apiKey = "fc4930a1480d39ef7b55f679e98a1afa"

        #if DEBUG
        let currencyData: [CurrencyService.Endpoint: String] = [
            .currencyList: "currencies",
            .liveQuotes: "usd_quotes"
        ]
        let testData = TestData(currencyService: currencyData)
        shared = .testing(baseURL: baseURL, testData: testData)

        #else
        shared = .default(baseURL: baseURL, apiKey: apiKey)
        #endif

    }

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {

        store = .init(initialState: .initial,
                      reducer: appReducer(state:action:),
                      middleware: [StoreType.createThunkMiddleware(), StoreType.createLoggerMiddleware()])

        // Create the SwiftUI view that provides the window contents.
        let contentView = ExchangeRateView()

        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)
            self.window = window
            window.makeKeyAndVisible()
        }
    }
}
