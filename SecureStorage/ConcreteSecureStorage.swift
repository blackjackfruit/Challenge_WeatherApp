//
//  ConcreteSecureStorage.swift
//  WeatherApp
//
//  Created by vm1 on 9/25/23.
//

import Foundation

// NOTE: This can be a keychain implementation or in this case UserDefaults
// Exclude this class from compiling for release builds and only compiling
// the keychain version.
class ConcreteSecureStorage: SecureStorage {
    var userdefaults: UserDefaults {
        get {
            return UserDefaults.standard
        }
    }
    
    func save(key: StorageKey, value: Any) {
        userdefaults.set(value, forKey: key.rawValue)
    }
    func retrieve(key: StorageKey) -> Any? {
        return userdefaults.object(forKey: key.rawValue)
    }

    func remove(key: StorageKey) {
        userdefaults.set(nil, forKey: key.rawValue)
    }
}
