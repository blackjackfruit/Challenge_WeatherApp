//
//  Network.swift
//  WeatherApp
//
//  Created by iury on 9/26/23.
//

import Foundation

protocol Network {
    func execute(request: URLRequest) async throws -> (Data, URLResponse)
}
