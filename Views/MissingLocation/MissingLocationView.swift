//
//  MissingLovationView.swift
//  WeatherApp
//
//  Created by vm1 on 9/25/23.
//

import SwiftUI

struct MissingLocationView: View {
    @State private var addLocationPopOverVisible = false

    var body: some View {
        VStack {
            presentAddLocationButton()
            Text("Please Add a Location")
        }
        .padding()
    }
    
    func presentAddLocationButton() -> some View {
        Button {
            addLocationPopOverVisible = true
        } label: {
            Image(systemName: "plus.circle")
                .font(.system(size: 40))
                .padding(10)
        }
        .popover(isPresented: $addLocationPopOverVisible) {
            UpdateLocationView(
                viewDisplayed: $addLocationPopOverVisible
            )
        }
    }
}

struct MissingLovationView_Previews: PreviewProvider {
    static var previews: some View {
        MissingLocationView()
    }
}
