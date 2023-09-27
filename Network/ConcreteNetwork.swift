//
//  File.swift
//  WeatherApp
//
//  Created by iury on 9/26/23.
//

import Foundation

class ConcreteNetwork: Network {
    static let shared = ConcreteNetwork()
    
    func execute(request: URLRequest) async throws -> (Data, URLResponse) {
        return try await URLSession.shared.data(for: request)
    }
}
