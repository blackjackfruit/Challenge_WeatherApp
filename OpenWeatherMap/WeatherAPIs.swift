//
//  WeatherAPIs.swift
//  WeatherApp
//
//  Created by vm1 on 9/25/23.
//

import Foundation
import Combine
import CoreLocation
import UIKit

enum WeatherTypes {
    case today
    case date(Date) // NOTE: Not implemented but possible
    case week // NOTE: Not implemented but possible
}

struct WeatherInformation {
    let weatherIcon: UIImage
    let locationName: String
    let currentTemperature: Double
    let feelsLike: Double
    let minTemp: Double
    let maxTemp: Double
    let humidity: Int
    let latitude: CLLocationDegrees
    let longitude: CLLocationDegrees
    let description: String
}

// Abstraction for potentially supporting other for weather
protocol WeatherAPIs {
    var currentWeather: PassthroughSubject<WeatherInformation, Error> { get }

    func queryWeather(for endpoint: Endpoint, type: WeatherTypes)
}

struct EndpointParameters {
    let path: String
    var queryItems: [URLQueryItem]
}

protocol Endpoint {
    var parameters: EndpointParameters { get }
}

enum OpenWeatherMapEndpoint: Endpoint {
    case weatherCoordinate(Location)
    var parameters: EndpointParameters {
        switch self {
        case .weatherCoordinate(let location):
            return EndpointParameters(
                path: "/data/2.5/weather",
                queryItems: [
                    URLQueryItem(name: "lat", value: "\(location.lat)"),
                    URLQueryItem(name: "lon", value: "\(location.lon)"),
                    URLQueryItem(name: "units", value: "imperial"),
                    URLQueryItem(name: "appid", value: API_KEY)
                ]
            )
        }
    }
}

class OpenWeatherRequestBuilder {
    private let scheme: String = "https"
    private let host: String = "api.openweathermap.org"
    private var endpoint: Endpoint
    
    init(endpoint: Endpoint){
        self.endpoint = endpoint
    }
    func build() -> URLRequest? {
        let parameters = endpoint.parameters
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = parameters.path
        components.queryItems = parameters.queryItems
        
        guard let url = components.url else {
            return nil
        }
        return URLRequest(url: url)
    }
}

class OpenWeatherMap: ObservableObject, WeatherAPIs {
    var currentWeather: PassthroughSubject<WeatherInformation, Error> = PassthroughSubject<WeatherInformation, Error>()
    static let shared = OpenWeatherMap()
    
    private let assetStorage: AssetStorage
    private let network: Network

    private init(
        assetStorage: AssetStorage = ConcreteOpenWeatherMapAssetStorage.shared,
        network: Network = ConcreteNetwork.shared
    ) {
        self.assetStorage = assetStorage
        self.network = network
    }
    
    func queryWeather(for endpoint: Endpoint, type: WeatherTypes) {
        guard let request = OpenWeatherRequestBuilder(endpoint: endpoint).build() else {
            // TODO: Throw some error
            return
        }
        Task { // TODO: Need to ensure that this task only executes once and not multiple times
            do {
                let (data, _) = try await network.execute(request: request)
                // TODO: Do checks here to return appropriate error if not 2xx response
                
                let weatherInformationServer = try JSONDecoder().decode(WeatherInformationServer.self, from: data)
                guard
                    let firstIconName = weatherInformationServer.weather.first?.icon,
                    let image = await assetStorage.retrieveImageAsset(name: firstIconName)
                else {
                    // TODO: Throw appropriate error for missing information pertaining to WeatherInformation
                    DispatchQueue.main.async {
                        self.currentWeather.send(completion: .failure(AppError(friendlyMessage: "Unable to retrieve Asset")))
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    let weatherInformation = WeatherInformation(
                        weatherIcon: image,
                        locationName: weatherInformationServer.name,
                        currentTemperature: weatherInformationServer.main.temp,
                        feelsLike: weatherInformationServer.main.feelsLike,
                        minTemp: weatherInformationServer.main.tempMin,
                        maxTemp: weatherInformationServer.main.tempMax,
                        humidity: weatherInformationServer.main.humidity,
                        latitude: weatherInformationServer.coord.lat,
                        longitude: weatherInformationServer.coord.lon,
                        description: weatherInformationServer.weather.description
                    )
                    self.currentWeather.send(weatherInformation)
                }
                print(weatherInformationServer)
            } catch {
                DispatchQueue.main.async {
                    self.currentWeather.send(completion: .failure(AppError(friendlyMessage: "Unable to communicate with server")))
                }
            }
        }
    }
}
