//
//  CurrencyPicker.swift
//  Currency
//
//  Created by Michael Haß on 18.05.20.
//  Copyright © 2020 Michael Hass. All rights reserved.
//

import SwiftUI

struct CurrencyPicker: View {
    var currencies: [CurrencyIdentifier]
    private let onSelect: (CurrencyIdentifier) -> Void

    init(currencies: [CurrencyIdentifier], onSelect: @escaping (CurrencyIdentifier) -> Void) {
        self.currencies = currencies
        self.onSelect = onSelect
    }

    var body: some View {
        NavigationView {
            GeometryReader { proxy in
                List {
                    ForEach(self.currencies, id: \.id) { element in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.white)
                                .onTapGesture {
                                    self.onSelect(element)
                            }

                            Text("\(element.abbr) - \(element.name)").lineLimit(1)

                        }.frame(width: proxy.frame(in: .local).size.width - 28)
                    }
                }
            }.navigationBarTitle("Select currency")
        }
    }
}
struct CurrencyPicker_Previews: PreviewProvider {
    static var previews: some View {
        CurrencyPicker.init(currencies: [.init(abbr: "ABR", name: "TEST NAMAE")],
                            onSelect: { _ in })
    }
}
