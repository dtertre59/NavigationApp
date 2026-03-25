//
//  ContentView.swift
//  NavigationApp
//
//  Created by David Tertre on 1/11/25.
//

import SwiftUI
import MapKit
import CoreLocation

@MainActor
struct ContentView: View {
    // The root view "owns" the view model.
    // @StateObject ensures the ObservableObject is created once and its lifetime is tied to this view.
    // 'private' encapsulates the dependency so only ContentView can access/replace it.
    @StateObject private var viewModel: MapViewModel

    // Designated initializer for injection (useful for previews/tests).
    init(viewModel: MapViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    // Convenience initializer that builds the default on the main actor.
    init() {
        _viewModel = StateObject(wrappedValue: MapViewModel(placesRepository: LocalPlacesRepository()))
    }
    
    var body: some View {
        // Child views observe the view model that is owned by this root view.
        MapView(vm: viewModel)
    }
}

#Preview("ContentView - Empty") {
    ContentView(viewModel: .emptyPreview)
}

#Preview("ContentView - With Pins") {
    ContentView(viewModel: .withPinsPreview)
}

#Preview("ContentView - Navigation") {
    ContentView(viewModel: .navigationPreview)
}
