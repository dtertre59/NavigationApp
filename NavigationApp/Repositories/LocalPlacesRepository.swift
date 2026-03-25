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
class LocalPlacesRepository: PlacesRepository, ObservableObject {
    
    @Published private var places: [Place] = []
    
    // Cumple el contrato del Protocolo al transformar el @Published en un AnyPublisher
    var placesPublisher: AnyPublisher<[Place], Never> {
            // $Places es el Publisher del array, lo convertimos a AnyPublisher
            return $places.eraseToAnyPublisher()
        }
    
    // Init samples
    
    init() {
        fetchPlaces()
    }
    
    // Acciones: Todas las modificaciones deben hacerse a la propiedad @Published
    
    func fetchPlaces() {
        self.places = [
            Place(  // id: UUID(),
                  name: "Parque El Pozo",
                  description: "Pequeño parque urbano con zona infantil, bancos y árboles, ideal para pasear o descansar en el centro de Colmenarejo.",
                  coordinates: CLLocationCoordinate2D(latitude: 40.563072, longitude: -4.017154)
                 ),
            Place(  // id: UUID(),
                  name: "Parque El Tupi",
                  description: "Area verde con columpios y espacios abiertos para jugar o pasear, muy frecuentada por familias y vecinos de la zona.",
                  coordinates: CLLocationCoordinate2D(latitude: 40.564309, longitude: -4.016559)
                 ),
            Place(  // id: UUID(),
                  name: "Ayuntamiento de Colmenarejo",
                  description: "Edificio principal de la administración local, donde se gestionan los servicios municipales y se celebran actos institucionales del municipio.",
                  coordinates: CLLocationCoordinate2D(latitude: 40.560863, longitude: -4.016605)
                 )
        ]
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


