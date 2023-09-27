//
//  WeatherView.swift
//  WeatherApp
//
//  Created by vm1 on 9/25/23.
//

import SwiftUI

struct WeatherView: View {
    private let location: Location
    @State private var updateViewLocation: Bool = false
    @StateObject private var viewModel = WeatherViewModel()
    
    init(location: Location) {
        self.location = location
    }
    
    var body: some View {
        VStack {
            currentWeatherInformation()
            Spacer()
        }
        .task {
            self.viewModel.startLoadingWeatherInformation(
                location: self.location,
                type: WeatherTypes.today
            )
        }
        .padding(5)
    }
    
    @ViewBuilder
    func currentWeatherInformation() -> some View {
        if viewModel.isLoadingInformation {
            ProgressView()
        }
        else if let errorMessage = viewModel.errorMessage {
            Text(errorMessage)
        }
        else {
            if let weatherInformation = viewModel.weatherInformation {
                Text(weatherInformation.locationName)
                Image(uiImage: weatherInformation.weatherIcon)
                
                Text("Current Temperature: " + (weatherInformation.currentTemperature.description))
                Text("Feels Like: " + (weatherInformation.feelsLike.description))
                Text("Max Temperature: " + (weatherInformation.maxTemp.description))
                Text("Min Temperature: " + (weatherInformation.minTemp.description))
                Text("Humidity: " + (weatherInformation.humidity.description))
            } else {
                Text("Failed to process weather information")
            }
        }
    }
}

struct WeatherView_Previews: PreviewProvider {
    static var previews: some View {
        WeatherView(location: Location(lat: 0.0, lon: 0.0))
    }
}
