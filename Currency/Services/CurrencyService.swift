//
//  CurrencyService.swift
//  Currency
//
//  Created by Michael Haß on 17.05.20.
//  Copyright © 2020 Michael Hass. All rights reserved.
//

import Foundation
import Combine

/// Service for performing request against the currency API
final class CurrencyService {

    // MARK: Nested types

    enum Endpoint: CaseIterable {
        case liveQuotes
        case currencyList

        var relativePath: String? {
            switch self {
            case .liveQuotes:
                return "live"
            case .currencyList:
                return "list"
            }
        }
    }

    typealias DecodingHandler<T> = (Data, HTTPURLResponse) throws -> T

    // MARK: Properties

    let baseURL: URL
    let apiKey: String
    let session: URLSession

    // MARK: Init

    init(baseURL: URL, apiKey: String, session: URLSession) {
        self.baseURL = baseURL
        self.apiKey = apiKey
        self.session = session
    }

    private var cancellable: Set<AnyCancellable> = .init()

    // MARK: API

    /// Creates URLSessionTasks to request a codable object from the specified endpoint
    ///
    /// - Parameters:
    ///   - endpoint: The endpoint to request data from
    ///   - decode: Closure to create a native object from the response data.
    ///   - completion: Excuted if task finished loading.
    /// - Returns: URLSessionTask if task could be created
    func request<T: Decodable>(_ endpoint: Endpoint,
                               decode: @escaping DecodingHandler<T>) -> AnyPublisher<T, Swift.Error>? {

        urlRequest(for: endpoint).map { request in
            session.dataTaskPublisher(for: request)
                .tryMap { (data, response) -> T in
                    guard let response = response as? HTTPURLResponse else {
                        throw Error.noResponse
                    }

                    if let error = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                        throw Error.errorResponse(error)
                    }

                    return try decode(data, response)

                }.receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
    }

    /// Constructs an URLRequest for the given Endpoint.
    ///
    /// - Parameter endpoint: Endpoint to construct the request for
    /// - Returns: Returns and URLRequest object if construction was successful.
    private func urlRequest(for endpoint: Endpoint) -> URLRequest? {
        // For now every endpoint acts the same.
        endpoint.relativePath.flatMap {
            let url = baseURL.appendingPathComponent($0)
            var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
            components?.queryItems = [authQueryItem]
            return components
                .flatMap(\.url)
                .map { URLRequest(url: $0) }
        }
    }

    private var authQueryItem: URLQueryItem {
        .init(name: "access_key", value: apiKey)
    }

    func store(cancellable: AnyCancellable) {
        cancellable.store(in: &self.cancellable)
    }
}

// MARK: - CurrencyService Error

extension CurrencyService {

    enum Error: Swift.Error {
        case noResponse
        case errorResponse(ErrorResponse)
    }

    struct ErrorResponse: Decodable {
        let code: Int
        let type: String
        let info: String

        enum CodingKeys: String, CodingKey {
            case error

            enum Resonse: String, CodingKey {
                case code
                case type
                case info
            }
        }

        init(from decoder: Decoder) throws {
            let rootContainer = try decoder.container(keyedBy: CodingKeys.self)
            let responseContainer = try rootContainer.nestedContainer(keyedBy: CodingKeys.Resonse.self,
                                                                      forKey: .error)

            code = try responseContainer.decode(Int.self, forKey: .code)
            info = try responseContainer.decode(String.self, forKey: .info)
            type = try responseContainer.decode(String.self, forKey: .type)
        }
    }
}

extension CurrencyService {
    static func testing(baseURL: URL, testData: [Endpoint: String]) -> CurrencyService {
        CurrencyServiceMocking.setTestData(testData: testData, baseURL: baseURL)
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [CurrencyServiceMocking.self]
        let session = URLSession(configuration: config)
        return .init(baseURL: baseURL, apiKey: "TEST_KEY", session: session)
    }
}
