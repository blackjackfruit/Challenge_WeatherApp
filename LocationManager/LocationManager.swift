//
//  LocationManager.swift
//  WeatherApp
//
//  Created by iury on 9/26/23.
//

import Foundation
import Combine
import CoreLocation

protocol LocationManager {
    var lastKnownLocation: PassthroughSubject<CLLocation, AppError> { get }
    
    func startObserving()
    
    // NOTE: Since there is no need to stop observing per the requirment, function is omitted
}
