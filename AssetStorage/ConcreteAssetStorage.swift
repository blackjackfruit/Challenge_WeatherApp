//
//  ConcreteAssetStorage.swift
//  WeatherApp
//
//  Created by iury on 9/26/23.
//

import Foundation
import UIKit

class ConcreteOpenWeatherMapAssetStorage: AssetStorage {
    static let shared = ConcreteOpenWeatherMapAssetStorage()
    private var cache: NSCache<NSString, UIImage> = NSCache<NSString, UIImage>()
    private let network: Network
    
    init(network: Network = ConcreteNetwork.shared) {
        self.network = network
    }
    
    let imageNames = [
        "01d",
        "01n",
        "02d",
        "02n",
        "03d",
        "03n",
        "04d",
        "04n",
        "09d",
        "09n",
        "10d",
        "10n",
        "11d",
        "11n",
        "13d",
        "13n",
        "50d",
        "50n"
    ]
    
    // This is called the moment the ContentViewModel is initialized in the background
    func predownloadAssets() {
        Task {
            async let i1 = retrieveImageAsset(name: imageNames[0])
            async let i2 = retrieveImageAsset(name: imageNames[1])
            async let i3 = retrieveImageAsset(name: imageNames[2])
            async let i4 = retrieveImageAsset(name: imageNames[3])
            async let i5 = retrieveImageAsset(name: imageNames[4])
            async let i6 = retrieveImageAsset(name: imageNames[5])
            async let i7 = retrieveImageAsset(name: imageNames[6])
            async let i8 = retrieveImageAsset(name: imageNames[7])
            async let i9 = retrieveImageAsset(name: imageNames[8])
            async let i10 = retrieveImageAsset(name: imageNames[9])
            async let i11 = retrieveImageAsset(name: imageNames[10])
            async let i12 = retrieveImageAsset(name: imageNames[11])
            async let i13 = retrieveImageAsset(name: imageNames[12])
            async let i14 = retrieveImageAsset(name: imageNames[13])
            async let i15 = retrieveImageAsset(name: imageNames[14])
            async let i16 = retrieveImageAsset(name: imageNames[15])
            async let i17 = retrieveImageAsset(name: imageNames[16])
            async let i18 = retrieveImageAsset(name: imageNames[17])
            
            let allImages = await [i1,i2,i3,i4,i5,i6,i7,i8,i9,i10,i11,i12,i13,i14,i15,i16,i17,i18]
            
            if allImages.contains(where: { $0 == nil }){
                print("Not all images downloaded")
            } else {
                print("All images downloaded")
            }
        }
    }
    
    func retrieveImageAsset(name: String) async -> UIImage? {
        if let image = cache.object(forKey: name as NSString) {
            return image
        }
        guard let url = URL(string: "https://openweathermap.org/img/wn/\(name)@2x.png") else {
            return nil
        }
        do {
            let (data, _) = try await network.execute(request: URLRequest(url: url))
            // TODO: Typically check response value here to return appropriate error
            guard let image = UIImage(data: data) else {
                return nil
            }
            cache.setObject(image, forKey: name as NSString)
            return image
        } catch {
            
        }
        // Image doesn't exist for some reason, fetch it again
        return nil
    }
}
