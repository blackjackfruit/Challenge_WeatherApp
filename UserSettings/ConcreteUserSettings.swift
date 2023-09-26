//
//  UserSettings.swift
//  WeatherApp
//
//  Created by vm1 on 9/25/23.
//

import Foundation
import Combine

// NOTE: These errors pertain to high level errors like encoding, saving, etc. so to not be specific
// to a technology like keychain or userdefaults.
enum UserSettingError: Error {
    case unableToEncodeObject
}

class ConcreteUserSettings: UserSettings {
    private let secureStorage: SecureStorage
    static let shared = ConcreteUserSettings()
    let publishers = PassthroughSubject<Location?, Never>()
    
    private init(secureStorage: SecureStorage = ConcreteSecureStorage()) {
        self.secureStorage = secureStorage
    }
    
    func setLocation(_ location: Location?) throws {
        do {
            let encoded = try JSONEncoder().encode(location)
            secureStorage.save(key: .lastSavedLocation, value: encoded)
            publishers.send(location)
        } catch {
            // TODO: Throw some known UserSettings Error
            throw UserSettingError.unableToEncodeObject
        }
    }
    
    func getLastSavedLocation() -> Location? {
        guard let data = secureStorage.retrieve(key: .lastSavedLocation) as? Data else {
            return nil
        }
        do {
            let decoded = try JSONDecoder().decode(Location.self, from: data)
            return decoded
        } catch {
            return nil
        }
    }
}
