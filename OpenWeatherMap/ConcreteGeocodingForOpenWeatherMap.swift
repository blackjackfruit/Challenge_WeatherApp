//
//  ConcreteGeocoding.swift
//  WeatherApp
//
//  Created by iury on 9/26/23.
//

import Foundation
import Combine
import CoreLocation

protocol Geocoding {
    var coordinate: PassthroughSubject<CLLocation, AppError> { get }
    
    func resolveTextToCoordinate(for text: String)
}

enum OpenWeatherMapGeocodingEnpoint: Endpoint {
    case textToCoordinateZipcode(String)
    case textToCoordinateCityState(String, String)
    case textToCoordinateCityStateCountry(String, String, String)
    
    var parameters: EndpointParameters {
        var endpointParameter: EndpointParameters
        switch self {
        case .textToCoordinateZipcode(let zipcode):
            endpointParameter = EndpointParameters(path: "/geo/1.0/zip", queryItems: [URLQueryItem(name: "zip", value: "\(zipcode),US")])
        case .textToCoordinateCityState(let city, let state):
            endpointParameter = EndpointParameters(path: "/geo/1.0/direct", queryItems: [URLQueryItem(name: "q", value: "\(city),\(state),US")])
        case .textToCoordinateCityStateCountry(let city, let state, let country):
            endpointParameter = EndpointParameters(path: "/geo/1.0/direct", queryItems: [URLQueryItem(name: "q", value: "\(city),\(state),\(country)")])
        }
        endpointParameter.queryItems.append(URLQueryItem(name: "limit", value: "1"))
        endpointParameter.queryItems.append(URLQueryItem(name: "appid", value: API_KEY))
        return endpointParameter
    }
}

class ConcreteGeocodingForOpenWeatherMap: Geocoding {
    
    static let shared = ConcreteGeocodingForOpenWeatherMap()
    var coordinate: PassthroughSubject<CLLocation, AppError> = PassthroughSubject<CLLocation, AppError>()
    
    func resolveTextToCoordinate(for text: String) {
        let components = text.components(separatedBy: " ")
        let endpoint: Endpoint
        if components.count == 2 {
            endpoint = OpenWeatherMapGeocodingEnpoint.textToCoordinateCityState(components[0], components[1])
            download(from: endpoint) { [weak self] (result: Result<[GeocodingCityStateServer], AppError>) in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let array):
                        if let geocoding = array.first {
                            let location = CLLocation(latitude: geocoding.lat, longitude: geocoding.lon)
                            self?.sendLocation(location)
                        } else {
                            self?.sendError()
                        }
                    case .failure(_):
                        self?.sendError()
                    }
                }
            }
        } else if components.count == 1 && components.first?.isEmpty == false {
            endpoint = OpenWeatherMapGeocodingEnpoint.textToCoordinateZipcode(components.first!)
            download(from: endpoint) { [weak self] (result: Result<GeocodingZipServer, AppError>) in
                switch result {
                case .success(let geocoding):
                    let location = CLLocation(latitude: geocoding.lat, longitude: geocoding.lon)
                    self?.sendLocation(location)
                case .failure(_):
                    self?.sendError()
                }
            }
        } else {
            self.sendError(AppError(friendlyMessage: "Not valid input"))
            return
        }
    }
    
    private func sendLocation(_ location: CLLocation) {
        DispatchQueue.main.async {
            self.coordinate.send(location)
        }
    }
    
    private func sendError(_ error: AppError = AppError(friendlyMessage: "Placeholder error")) {
        DispatchQueue.main.async {
            self.coordinate.send(completion: .failure(error))
            self.coordinate = PassthroughSubject<CLLocation, AppError>()
        }
    }
    
    private func download<T: Codable>(from endpoint: Endpoint, completion: @escaping (Result<T, AppError>) -> Void)  {
        guard let request = OpenWeatherRequestBuilder(endpoint: endpoint).build() else {
            coordinate.send(completion: .failure(AppError(friendlyMessage: "Not able to build request")))
            return completion(.failure(AppError(friendlyMessage: "")))
        }
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(for: request)
                // TODO: Do checks here to return appropriate error if not 2xx response
                
                let returnValue: T = try JSONDecoder().decode(T.self, from: data)
                
                completion(.success(returnValue))
            } catch {
                // TODO: Throw appropriate error for missing information pertaining to WeatherInformation
                sendError()
            }
        }
    }
}
