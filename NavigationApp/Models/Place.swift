//
//  Place.swift
//  NavigationApp
//
//  Created by David Tertre on 7/11/25.
//

import Foundation
import CoreLocation

struct Place: Identifiable, Hashable {
    var id: UUID = UUID()
    var name: String
    var description: String
    var coordinates: CLLocationCoordinate2D
    
    static func == (lhs: Place, rhs: Place) -> Bool {
            lhs.id == rhs.id
        }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
