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

    static func setTestData(testData: [URL: String]) {
        setTestData(testData:
            testData.compactMapValues({ name in
                Bundle.main.url(forResource: name, withExtension: ".json")
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

        guard let url = request.url, let data = CurrencyServiceMocking.testData[url] else {
            return
        }
        client?.urlProtocol(self, didLoad: data)
    }

    override func stopLoading() {
    }
}
