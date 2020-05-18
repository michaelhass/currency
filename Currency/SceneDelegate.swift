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

        // Use either the standard shared object that communicates
        // Remotely with every registered service.

        let apiKey = "YOUR_KEY"
        shared = defaultShared(withKey: apiKey)

        // OR

        // Use the testing evironment.
        // Responses are in the directory 'Mocking'

        // shared = testShared()
    }

    private func testShared() -> Shared {
        let baseURL = URL(string: "https://duckduckgo.com/")!

        let currencyData: [CurrencyService.Endpoint: String] = [
                .currencyList: "currencies",
                .liveQuotes: "usd_quotes"
            ]
        let testData = TestData(currencyService: currencyData)
        return .testing(baseURL: baseURL, testData: testData)
    }

    private func defaultShared(withKey key: String) -> Shared {
        // NOTE: Free subscription plan does not support HTTPS
        let baseURL = URL(string: "http://api.currencylayer.com/")!
        return .default(baseURL: baseURL, apiKey: key)
    }

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {

        let loadedState: AppState? = try? shared?.appStateCache?.load()
        var middleware: [Middleware<AppState>] = [createThunkMiddleware(), createLoggerMiddleware()]
        if let cache = shared?.appStateCache { middleware.append(createCacheMiddleware(cache: cache)) }

        store =  .init(initialState: loadedState ?? AppState.initial,
                       reducer: appReducer(state:action:),
                       middleware: middleware)

        // Create the SwiftUI view that provides the window contents.
        let contentView = ExchangeRateView().environmentObject(store!)

        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)
            self.window = window
            window.makeKeyAndVisible()
        }
    }
}
