//
//  Collections+ShortDescription.swift
//  Currency
//
//  Created by Michael Haß on 18.05.20.
//  Copyright © 2020 Michael Hass. All rights reserved.
//

import Foundation

//extension Dictionary {
//    func shortDescriptor(maxElements: Int) -> String {
//        var text = ""
//
//        for enumeration in self.enumerated() {
//            guard enumeration.offset < maxElements else {
//                break
//            }
//
//            text += "'\(enumeration.element.key)': \(enumeration.element.value), "
//        }
//
//        if !text.isEmpty {
//            text += "... count: \(self.count)"
//        }
//
//        return "[\(text)]"
//    }
//}

extension Collection {

    func shortDescriptor(maxElements: Int) -> String {
        var text = ""

        for (index, element) in self.enumerated() {

            guard index < maxElements else {
                break
            }

            text += "'\(element), "
        }

        if !text.isEmpty {
            text += "... count: \(self.count)"
        }

        return "[\(text)]"
    }

}
