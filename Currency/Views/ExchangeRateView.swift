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

    @State private var showPicker: Bool = false
    @State private var selectedCurrency: CurrencyIdentifier?
    @State private var attributes: Attributes = .init(currencyState: nil)

    @State private var currencies: [CurrencyIdentifier] = []
    @State private var results: [ExchangeResult] = []

    // MARK: View properties

    private static let numberFormatter: NumberFormatter = {
         let numberFormatter = NumberFormatter()
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2
        return numberFormatter
    }()

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
            self.results = state.currencyState.result
            self.selectedCurrency = state.currencyState.selectedCurrency
            self.attributes = Attributes(currencyState: state.currencyState)
        }
    }

    func content() -> some View {
        ZStack {
            List {
                ForEach(self.results, id: \.id, content: resultView(for:))

            }.listStyle(PlainListStyle()).gesture(DragGesture().onChanged({ _  in
                UIApplication.shared.dismissKeyboard()
            }))

            message(text: attributes.message)
                .opacity(attributes.message.isEmpty ? 0 : 1)
        }
    }

    func resultView(for result: ExchangeResult) -> some View {
        let exchangeAmount = ExchangeRateView.numberFormatter.string(from: NSNumber(value: result.exchangeAmount)) ?? ""
        return VStack(alignment: .leading, spacing: 4) {
            Text("\(result.currency.abbr) \(exchangeAmount)")
                .lineLimit(1)
            Text("\(result.currency.name)")
                .font(.caption)
                .lineLimit(1)
            }
    }

    func header() -> some View {
        VStack {
            InputForm(observer: Observer(dispatch: store.dispatch(action:),
                                         selectedCurrency: self.selectedCurrency))

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

extension ExchangeRateView {

    struct Attributes {
        let currencyState: CurrencyState?

        var isCurrencySelectDisabled: Bool {
            currencyState.map(\.currencies.isEmpty) ?? false
        }

        var isSendDisabled: Bool {
            isCurrencySelectDisabled || currencyState?.selectedCurrency == nil
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
        private let dispatch: DispatchFunction
        private let selectedCurrency: CurrencyIdentifier?

        init(dispatch: @escaping DispatchFunction,
             selectedCurrency: CurrencyIdentifier?) {
            self.selectedCurrency = selectedCurrency
            self.dispatch = dispatch
        }

        func editingStarted() {
            // Do nothing
        }

        func editingEnded(text: String) {
            requestRates(amountText: text)
        }

        func editingCanceled() {
            // Do nothing
        }

        func textChanged(text: String) {
            requestRates(amountText: text)
        }

        private func requestRates(amountText: String) {
            Float(amountText)
                .map(CurrencyActions.SetAmount.init(amount:))
                .map(dispatch)

            shared
                .map(\.currencyService)
                .map { CurrencyActions.requestRates(service: $0) }
                .map(dispatch)
        }
    }
}
