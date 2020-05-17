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

    static func setTestData(testData: [URL: URL]) {
        self.testData = testData.reduce(into: [:]) { (result, element) in
            guard let data = try? Data(contentsOf: element.value) else { return }
            result[element.key] = data
        }
    }

    static func setTestData(testData: [CurrencyService.Endpoint: String], baseURL: URL) {
        setTestData(testData:
            testData.reduce(into: [URL: URL](), { (result, element) in
                guard let key = element.key.relativePath.map(baseURL.appendingPathComponent(_:)) else {
                    return
                }
                result[key] = Bundle.main.url(forResource: element.value, withExtension: ".json")
            })
        )
    }

    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canInit(with task: URLSessionTask) -> Bool {
        return true
    }

    // ignore this method; just send back what we were given
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        defer {
            client?.urlProtocolDidFinishLoading(self)
        }

        _ = request.url.flatMap { url -> URL? in
            // Remove query items
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            components?.queryItems = nil
            return components?.url
        }.flatMap { url -> Data? in
            CurrencyServiceMocking.testData[url]
        }.map { data -> Void in
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocol(self, didReceive: HTTPURLResponse(), cacheStoragePolicy: .allowedInMemoryOnly)
            return Void()
        }
    }

    override func stopLoading() {
    }
}
