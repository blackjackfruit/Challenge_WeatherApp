// NOTE: Generated this file from https://app.quicktype.io/
// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let geocoding = try? JSONDecoder().decode(Geocoding.self, from: jsonData)

import Foundation

// MARK: - Geocoding
struct GeocodingZipServer: Codable {
    let zip, name: String
    let lat, lon: Double
    let country: String
}

// MARK: - GeocodingCityState
struct GeocodingCityStateServer: Codable {
    let name: String
    let localNames: LocalNames
    let lat, lon: Double
    let country, state: String

    enum CodingKeys: String, CodingKey {
        case name
        case localNames = "local_names"
        case lat, lon, country, state
    }
}

// MARK: - LocalNames
struct LocalNames: Codable {
    let en: String
}
