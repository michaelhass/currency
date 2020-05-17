//
//  ContentView.swift
//  Currency
//
//  Created by Michael Haß on 16.05.20.
//  Copyright © 2020 Michael Hass. All rights reserved.
//

import SwiftUI

struct ExchangeRateView: View {
    @EnvironmentObject var store: Store<AppState>

    var body: some View {
        Text("Hello, World!")
    }
}

struct ExchangeRateView_Previews: PreviewProvider {
    static var previews: some View {
        ExchangeRateView()
    }
}
