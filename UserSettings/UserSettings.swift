//
//  UserSettings.swift
//  WeatherApp
//
//  Created by vm1 on 9/25/23.
//

import Foundation
import CoreLocation
import Combine

// NOTE: Used custom location because there isn't a need for other CLLocation values
// also it is possible to incorporate other information such as city, state names, etc.
struct Location: Codable {
    let lat: CLLocationDegrees
    let lon: CLLocationDegrees
}

protocol UserSettings {
    var publishers: PassthroughSubject<Location?, Never> { get }
    func setLocation(_ location: Location?) throws
    func getLastSavedLocation() -> Location?
}
