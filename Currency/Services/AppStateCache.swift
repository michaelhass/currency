//
//  AppStateCache.swift
//  Currency
//
//  Created by Michael Haß on 18.05.20.
//  Copyright © 2020 Michael Hass. All rights reserved.
//

import Foundation

final class AppStateCache {

    let fileManager: FileManager
    let documentDirectory: URL
    let fileName: String = "appstate.currency.cache"

    init(fileManager: FileManager) throws {
        self.fileManager = fileManager
        documentDirectory = try FileManager.default.url(for: .documentDirectory,
                                                        in: .userDomainMask,
                                                        appropriateFor: nil,
                                                        create: false)
    }

    func store(_ appState: AppState) throws {
        let data = try JSONEncoder().encode(appState)
        let file = documentDirectory.appendingPathComponent(fileName)
        try data.write(to: file)
    }

    func load() throws -> AppState {
        let file = documentDirectory.appendingPathComponent(fileName)
        let data = try Data(contentsOf: file)
        return try JSONDecoder().decode(AppState.self, from: data)
    }
}
