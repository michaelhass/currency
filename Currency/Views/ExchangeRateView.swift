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
    @State private var currencies: [CurrencyIdentifier] = []
    @State private var showPicker: Bool = false
    @State private var selectedCurrency: CurrencyIdentifier?
    @State private var attributes: Attributes = .init(currencyState: nil)
    @State private var amount: Float?

    // MARK: View properties

    private let cornerRadius: CGFloat = 6

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 8) {
                header().padding()
                content()
            }.navigationBarTitle("Exchange rates", displayMode: .large)
        }.onAppear {
            // Load currencies
            shared
                .map(\.currencyService)
                .map(CurrencyActions.requestCurrencies(service:))
                .map(self.store.dispatch(action:))
        }.onReceive(store.$state) { state in
            self.currencies = state.currencyState.currencies
            self.attributes = Attributes(currencyState: state.currencyState)
        }
    }

    func content() -> some View {
        ZStack {
            List {
                ForEach(0..<10) { _ in
                    Text("Test")
                }
            }.listStyle(PlainListStyle()).gesture(DragGesture().onChanged({ _  in
                UIApplication.shared.dismissKeyboard()
            }))

            message(text: attributes.message)
                .opacity(attributes.message.isEmpty ? 0 : 1)
        }
    }

    func header() -> some View {
        VStack {
            InputForm(observer: Observer())

            HStack {
                Button(selectedCurrency?.abbr ?? "Select currency") {
                    self.showPicker.toggle()
                }
                .disabled(attributes.isCurrencySelectDisabled)
                .sheet(isPresented: $showPicker) {
                    CurrencyPicker(currencies: self.currencies) { currency in
                        self.selectedCurrency = currency
                        // dispatch
                        self.showPicker = false
                    }
                }

                Spacer()

                Button("Send") {
                    UIApplication.shared.dismissKeyboard()
                }
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

extension ExchangeRateView {

    struct Attributes {
        let currencyState: CurrencyState?

        var isCurrencySelectDisabled: Bool {
            currencyState.map(\.currencies.isEmpty) ?? false
        }

        var isSendDisabled: Bool {
            currencyState?.amount == nil || currencyState?.selectedCurrency == nil
        }

        var message: String {
            switch currencyState?.requestState {
            case .fetching?:
                return "Updating data"
            case .error:
                return "Oh no, an error occured."
            default:
                return ""
            }
        }
    }

    private struct Observer: InputFormObserver {
        func editingStarted() {
            // Do nothing
        }

        func editingEnded() {

        }

        func editingCanceled() {
            // Do nothing
        }

        func textChanged(text: String) {

        }
    }
}
