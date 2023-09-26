//
//  SecureStorage.swift
//  WeatherApp
//
//  Created by vm1 on 9/25/23.
//

import Foundation

enum StorageKey: String, CustomStringConvertible {
    case lastSavedLocation = "lastSavedLocation"
    var description: String {
        return self.rawValue
    }
}

protocol SecureStorage {
    func save(key: StorageKey, value: Any)
    func retrieve(key: StorageKey) -> Any?
    func remove(key: StorageKey)
}
