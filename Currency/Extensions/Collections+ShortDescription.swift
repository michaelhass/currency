//
//  Collections+ShortDescription.swift
//  Currency
//
//  Created by Michael Haß on 18.05.20.
//  Copyright © 2020 Michael Hass. All rights reserved.
//

import Foundation

extension Collection {

    func shortDescriptor(maxElements: Int) -> String {
        var text = ""

        for (index, element) in self.enumerated() where index < maxElements {
            text += "\(element), "
        }

        if !text.isEmpty {
            text += "... count: \(self.count)"
        }

        return "[\(text)]"
    }
}
