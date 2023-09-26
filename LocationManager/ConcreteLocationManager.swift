//
//  LocationManager.swift
//  WeatherApp
//
//  Created by vm1 on 9/25/23.
//

import Foundation
import CoreLocation
import Combine

class ConcreteLocationManager: NSObject, ObservableObject, LocationManager {
    var lastKnownLocation: PassthroughSubject<CLLocation, AppError> = PassthroughSubject<CLLocation, AppError>()
    private let manager: CLLocationManager = CLLocationManager()
    @Published var errorMessage: String = ""
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func startObserving() {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
            fallthrough
        case .authorizedAlways:
            fallthrough
        case .authorizedWhenInUse:
            manager.startUpdatingLocation()
        case .denied:
            fallthrough
        case .restricted:
            DispatchQueue.main.async {
                self.lastKnownLocation.send(completion: .failure(AppError(friendlyMessage: "Permission Denied")))
                self.lastKnownLocation = PassthroughSubject<CLLocation, AppError>()
            }
        }

        manager.requestLocation()
    }
}

extension ConcreteLocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let lastLocation = locations.last else {
            return
        }
        DispatchQueue.main.async {
            self.lastKnownLocation.send(lastLocation)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .denied:
            fallthrough
        case .restricted:
            DispatchQueue.main.async {
                self.lastKnownLocation.send(completion: .failure(AppError(friendlyMessage: "Access to location denied")))
//                self.lastKnownLocation = PassthroughSubject<CLLocation, AppError>()
            }
        case .notDetermined:
            print("Undetermined")
        default:
            print("TODO: Ignore for now")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // TODO: Missing error handling
    }
}
