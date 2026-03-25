//
//  LocalPlacesRepository.swift
//  NavigationApp
//
//  Created by David Tertre on 8/11/25.
//

import Foundation
import Combine
import CoreLocation


// It Losses info when the app is closed
class PlacesRepositoryMock: PlacesRepository, ObservableObject {
    
    @Published private var places: [Place] = []
    
    // Cumple el contrato del Protocolo al transformar el @Published en un AnyPublisher
    var placesPublisher: AnyPublisher<[Place], Never> {
            // $Places es el Publisher del array, lo convertimos a AnyPublisher
            return $places.eraseToAnyPublisher()
        }
    
    // Init samples
    init(initialPlaces: [Place]) {
        fetchPlaces()
        places = initialPlaces
    }
    
    // Acciones: Todas las modificaciones deben hacerse a la propiedad @Published
    
    func fetchPlaces() {
        self.places = []
    }
    
    func getPlaces() -> [Place] {
        return places
    }
    
    func addPlace(_ place: Place) {
        places.append(place)
    }
    
    func updatePlace(_ place: Place) {
        if let index = places.firstIndex(where: { $0.id == place.id }) {
            places[index] = place
        }
    }
    
    func deletePlace(_ place: Place) {
        places.removeAll { $0.id == place.id }
    }
}
