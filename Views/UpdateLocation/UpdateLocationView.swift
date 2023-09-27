//
//  AddLocationView.swift
//  WeatherApp
//
//  Created by vm1 on 9/25/23.
//

import SwiftUI

struct UpdateLocationView: View {
    @Binding var viewDisplayed: Bool
    @State private var locationText: String = ""
    @StateObject private var viewModel = UpdateLocationViewModel()
    
    var body: some View {
        if viewModel.didUpdateLocation {
            ProgressView().task {
                self.viewDisplayed = false
            }
        } else {
            VStack {
                renderSpecifyLocationOption()
                renderUseLocationOption()
                renderErrorMessage()
                Spacer()
            }
            .padding(10)
        }
    }
    
    @ViewBuilder
    func renderSpecifyLocationOption() -> some View {
        HStack {
            TextField(
                "Enter either \"zipcode\" or \"city state\"", text: $locationText
            )
            .autocorrectionDisabled(true)
            .autocapitalization(.none)
            let button = Button {
                viewModel.searchForLocation(text: locationText)
            } label: {
                Text("Use")
            }
            if viewModel.isSearchingForLocation {
                button.disabled(true)
            } else {
                button.disabled(false)
            }
        }
    }
    
    @ViewBuilder
    func renderUseLocationOption() -> some View {
        Button {
            viewModel.requestUserForCurrentLocation()
        } label: {
            Text("Use Current Location")
                .frame(maxWidth: .infinity)
        }
        .padding(5)
        .background(viewModel.isSearchingForLocation || viewModel.locationDisabled ? .gray : .blue)
        .cornerRadius(5)
        .foregroundColor(.white)
        .disabled(viewModel.isSearchingForLocation || viewModel.locationDisabled ? true : false)
    }
    
    @ViewBuilder
    func renderErrorMessage() -> some View {
        if let errorMessage = viewModel.errorMessage {
            Text(errorMessage)
        } else {
            EmptyView()
        }
    }
}

struct AddLocationView_Previews: PreviewProvider {
    static var previews: some View {
        UpdateLocationView(viewDisplayed: .constant(false))
    }
}
