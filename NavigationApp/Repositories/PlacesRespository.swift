//
//  PlacesRespository.swift
//  NavigationApp
//
//  Created by David Tertre on 8/11/25.
//

import Foundation
import Combine

protocol PlacesRepository {
    
    var placesPublisher: AnyPublisher<[Place], Never> { get }
    
    func fetchPlaces()
    func getPlaces() -> [Place]
    func addPlace(_ place: Place)
    func updatePlace(_ place: Place)
    func deletePlace(_ place: Place)
}
