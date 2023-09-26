//
//  AddLocationViewModel.swift
//  WeatherApp
//
//  Created by vm1 on 9/25/23.
//

import Foundation
import Combine
import CoreLocation

class UpdateLocationViewModel: ObservableObject {
    @Published var didUpdateLocation: Bool = false
    @Published var errorMessage: String?
    @Published var location: Location?
    @Published var isSearchingForLocation: Bool = false
    @Published var locationDisabled = false
    
    let locationManager: LocationManager = ConcreteLocationManager()
    let userSettings: UserSettings
    let geocoding: Geocoding
    var cancellable: AnyCancellable?
    init(
        userSettings: UserSettings = ConcreteUserSettings.shared,
        geocoding: Geocoding = ConcreteGeocodingForOpenWeatherMap.shared
    ) {
        self.userSettings = userSettings
        self.geocoding = geocoding
    }
    
    func listenToPassthroughChanges(for passthrough: PassthroughSubject<CLLocation, AppError>, shouldDisableLocation: Bool) {
        cancellable = passthrough
            .sink { [weak self] completionStatus in
            switch completionStatus {
            case .failure(let error):
                if shouldDisableLocation {
                    self?.locationDisabled = true
                }
                self?.errorMessage = error.friendlyMessage
            case .finished:
                print("Finished without error, log metric for happy case")
            }
            self?.isSearchingForLocation = false

        } receiveValue: { [weak self] systemLocation in
            do {
                try self?.userSettings.setLocation(Location(lat: systemLocation.coordinate.latitude, lon: systemLocation.coordinate.longitude))
                self?.didUpdateLocation = true
            } catch {
                self?.errorMessage = "Unable to save location"
            }
            self?.isSearchingForLocation = false
        }
    }
    
    func searchForLocation(text: String) {
        isSearchingForLocation = true
        listenToPassthroughChanges(for: geocoding.coordinate, shouldDisableLocation: false)
        geocoding.resolveTextToCoordinate(for: text)
    }

    func requestUserForCurrentLocation() {
        isSearchingForLocation = true
        listenToPassthroughChanges(for: locationManager.lastKnownLocation, shouldDisableLocation: true)
        locationManager.startObserving()
    }
}
