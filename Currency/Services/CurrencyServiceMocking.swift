//
//  CurrencyServiceMocking.swift
//  Currency
//
//  Created by Michael Haß on 17.05.20.
//  Copyright © 2020 Michael Hass. All rights reserved.
//

import Foundation

final class CurrencyServiceMocking: URLProtocol {

    private static var testData = [URL: Data]()

    static func setTestData(testData: [CurrencyService.Endpoint: String], baseURL: URL) {
        self.testData = testData.reduce(into: [URL: Data]()) { (result, element) in
            guard let key = element.key.relativePath.map(baseURL.appendingPathComponent(_:)) else {
                return
            }

            guard let url = Bundle(for: CurrencyServiceMocking.self)
                .url(forResource: element.value, withExtension: ".json") else {
                return
            }
            result[key] = try? Data(contentsOf: url)
        }
    }

    override func startLoading() {
        defer {
            // Always notify the client that the request is completed
            client?.urlProtocolDidFinishLoading(self)
        }

        request.url.flatMap { url -> URL? in
            // Remove query items
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            components?.queryItems = nil
            return components?.url
        }.flatMap { url -> Data? in
            CurrencyServiceMocking.testData[url]
        }.map { data -> Void in
            // TestData successfullly retrieved.
            // Notify the client with the retrieved data and and empty URLResponse.
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocol(self, didReceive: HTTPURLResponse(), cacheStoragePolicy: .allowedInMemoryOnly)
        }
    }

    // MARK: Required
    // NOTE: We have to override the following few functions, even though the implementation doesn't do much.
    // Otherwise the mocking process might not work properly.

    override func stopLoading() {
        // Do nothing
    }

    override class func canInit(with request: URLRequest) -> Bool {
        // Handle every request
        return true
    }

    override class func canInit(with task: URLSessionTask) -> Bool {
        // Handle every task
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        // Ignore
        return request
    }

}
