//
//  SceneDelegate.swift
//  Currency
//
//  Created by Michael Haß on 16.05.20.
//  Copyright © 2020 Michael Hass. All rights reserved.
//

import UIKit
import SwiftUI

struct Shared {
    let currencyService: CurrencyService
}

private(set) var shared: Shared?

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private typealias StoreType = Store<AppState>
    private var store: StoreType?

    override init() {
        super.init()

        let baseURL = URL(string: "https://api.currencylayer.com/")!
        // Place your api key here
        let apiKey = "fc4930a1480d39ef7b55f679e98a1afa"
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [CurrencyServiceMocking.self]
        let session = URLSession(configuration: config)
        let currencyService = CurrencyService(baseURL: baseURL, apiKey: apiKey, session: session)
        shared = .init(currencyService: currencyService)
    }

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {

        store = .init(initialState: .initial,
                      reducer: appReducer(state:action:),
                      middleware: [StoreType.createThunkMiddleWare(), StoreType.createLoggerMiddleware()])

        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView()

        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)
            self.window = window
            window.makeKeyAndVisible()
        }
    }
}
