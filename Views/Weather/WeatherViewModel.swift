//
//  WeatherViewModel.swift
//  WeatherApp
//
//  Created by vm1 on 9/25/23.
//

import Foundation
import Combine

class WeatherViewModel: ObservableObject {
    @Published var isLoadingInformation = true
    @Published var weatherInformation: WeatherInformation?
    @Published var errorMessage: String?
    
    let weather: WeatherAPIs
    var cancellable: AnyCancellable?
    
    init(weather: WeatherAPIs = OpenWeatherMap.shared) {
        self.weather = weather
        cancellable = self.weather.currentWeather.sink(receiveCompletion: { [weak self] completion in
            switch completion {
            case .failure(_):
                self?.errorMessage = "TODO: Unable to fetch weather"
                self?.isLoadingInformation = false
            case .finished:
                print("TODO: Log metric for success")
            }
        }, receiveValue: { [weak self] weatherInformation in
            self?.weatherInformation = weatherInformation
            self?.isLoadingInformation = false
        })
    }
    
    func startLoadingWeatherInformation(location: Location, type: WeatherTypes) {
        do {
            let endpoint = OpenWeatherMapEndpoint.weatherCoordinate(location)
            try weather.queryWeather(for: endpoint, type: type)
        } catch {
            errorMessage = "Failed to retrieve weather information"
        }
    }
}
