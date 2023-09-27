//
//  ContentView.swift
//  WeatherApp
//
//  Created by vm1 on 9/25/23.
//

import SwiftUI
import Combine

class ContentViewModel: ObservableObject {
    @Published var currentLocation: Location? = nil
    private let userSettings: UserSettings
    private var cancellable: AnyCancellable?
    init(
        userSettings: UserSettings = ConcreteUserSettings.shared,
        assetStorage: AssetStorage = ConcreteOpenWeatherMapAssetStorage.shared
    ) {
        self.userSettings = userSettings
        self.currentLocation = userSettings.getLastSavedLocation()
        self.cancellable = userSettings.publishers.sink { [weak self] location in
            self?.currentLocation = location
        }
        assetStorage.predownloadAssets()
    }
}

struct ContentView: View {
    @State var addLocationPopOverVisible = false
    @StateObject var viewModel = ContentViewModel()
    
    var body: some View {
        if API_KEY.count == 0 {
            Text("API key for OpenWeatherMap is empty. Search for API_KEY")
        }
        else if let location = viewModel.currentLocation  {
            WeatherView(location: location)
        }
        else {
            // This is only possible when the app first launches and the user never defined
            // a location. If the user had the ability to clear location then this would be
            // reached to prompt user to add location
            
            // Once location has been set in UserSettings, then this body will redraw with
            // a currentLocation triggering WeatherView to be rendered accordingly
            MissingLocationView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
