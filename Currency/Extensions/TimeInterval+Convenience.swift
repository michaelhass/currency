//
//  TimeInterval+Convenience.swift
//  Currency
//
//  Created by Michael Haß on 18.05.20.
//  Copyright © 2020 Michael Hass. All rights reserved.
//

import Foundation

extension TimeInterval {

    /// Checks whether self is older than the given time
    /// NOTE: Returns false, if self is in the future
    /// - Parameter minutes: age of time stamp to check
    /// - Returns: true if older
    func isOlderThan(minutes: Int) -> Bool {
        let diff = Date().timeIntervalSince1970 - self
        let compareTo: TimeInterval = TimeInterval(minutes) * 60
        return diff > compareTo
    }
}
