//
//  ContentView.swift
//  Currency
//
//  Created by Michael Haß on 16.05.20.
//  Copyright © 2020 Michael Hass. All rights reserved.
//

import SwiftUI

struct ExchangeRateView: View {

    // MARK: Bindings
    @EnvironmentObject var store: Store<AppState>
    @State private var attributes: Attributes = .init(currencyState: nil)

    // MARK: View properties

    private let cornerRadius: CGFloat = 6

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 8) {
                header().padding()
                content()
            }.navigationBarTitle("Exchange rates", displayMode: .large)

        }.onAppear {
            if self.attributes.shouldUpdateCurrencies {
                shared
                .map(\.currencyService)
                .map(CurrencyActions.requestCurrencies(service:))
                .map(self.store.dispatch(action:))
            }

            if self.attributes.canCalculateResult {
                self.store.dispatch(action: CurrencyActions.UpdateRates())
            }

        }.onReceive(store.$state) { state in
            self.attributes = Attributes(currencyState: state.currencyState)
        }
    }

    func content() -> some View {
        ZStack {
            List {
                ForEach(self.attributes.results, id: \.id, content: resultView(for:))

            }.listStyle(PlainListStyle()).gesture(DragGesture().onChanged({ _  in
                UIApplication.shared.dismissKeyboard()
            }))

            message(text: attributes.message)
                .opacity(attributes.message.isEmpty ? 0 : 1)
        }
    }

    func resultView(for result: ExchangeResult) -> some View {
        return VStack(alignment: .leading, spacing: 4) {
            Text("\(result.currency.abbr) \(attributes.numberString(for: result.exchangeAmount))")
                .lineLimit(1)
            Text("\(result.currency.name)")
                .font(.caption)
                .lineLimit(1)
            }
    }

    func header() -> some View {
        VStack {
            InputForm(
                observer: Observer(dispatch: store.dispatch(action:),
                                   selectedCurrency: self.attributes.selectedCurrency),
                initialValue: self.attributes.initialInputValue
            )

            HStack {
                Button(self.attributes.selectedCurrency?.abbr ?? "Select currency") {
                    self.attributes.showPicker.toggle()
                }
                .disabled(attributes.isCurrencySelectDisabled)
                .sheet(isPresented: $attributes.showPicker) {
                    CurrencyPicker(currencies: self.attributes.currencies) { currency in
                        self.attributes.showPicker = false

                        self.store.dispatch(action: CurrencyActions.SetSelectedCurrency(currency: currency))

                        shared
                            .map(\.currencyService)
                            .map(CurrencyActions.requestRates(service:))
                            .map(self.store.dispatch(action:))

                    }
                }

                Spacer()

                .disabled(attributes.isSendDisabled)
            }.padding(0) // Remove padding from HStack
        }
    }
    /// Returns a view with displaying the given text
    func message(text: String) -> some View {
        VStack {
            Spacer(minLength: 80)
            ZStack(alignment: .center) {
                Rectangle()
                    .fill(Color.gray.opacity(0.75))
                    .cornerRadius(cornerRadius)
                    .frame(width: 300, height: 150)

                Text(text)
                    .multilineTextAlignment(.center)
                    .cornerRadius(cornerRadius)
                    .background(Color.clear)
                    .foregroundColor(Color.white)
                    .frame(width: 300, height: 150)
            }

            Spacer()
        }
    }
}
