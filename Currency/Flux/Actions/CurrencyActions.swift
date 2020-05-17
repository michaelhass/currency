//
//  CurrencyActions.swift
//  Currency
//
//  Created by Michael Haß on 17.05.20.
//  Copyright © 2020 Michael Hass. All rights reserved.
//

import Foundation

struct CurrencyActions {

    private func decoder<T: Decodable>(for type: T.Type) -> CurrencyService.DecodingHandler<T> {
        return { data, _ in
            try JSONDecoder().decode(T.self, from: data)
        }
    }

    func requestCurrencyList<State>(service: CurrencyService) -> Thunk<State> {
        .init { (dispatch, state) in
            let endpoint = CurrencyService.Endpoint.currencyList
            dispatch(SetFetching(endoint: endpoint))
            service.request(endpoint, decode: self.decoder(for: CurrencyList.self)).map {
                $0.sink(receiveCompletion: {  completed in
                    guard case .failure(let error) = completed else { return }
                    dispatch(ShowError(error: error))
                }, receiveValue: { list in
                    dispatch(SetCurrencyList(list: list))
                })
            }.map(service.store(cancellable:))
        }
    }

    struct SetFetching: Action {
        let endoint: CurrencyService.Endpoint
    }

    struct ShowError: Action {
        let error: Swift.Error
    }

    struct SetCurrencyList: Action {
        let list: CurrencyList
    }
}
