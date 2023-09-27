//
//  AssetStorage.swift
//  WeatherApp
//
//  Created by iury on 9/26/23.
//

import Foundation
import UIKit

protocol AssetStorage {
    func predownloadAssets()
    func retrieveImageAsset(name: String) async -> UIImage?
}
