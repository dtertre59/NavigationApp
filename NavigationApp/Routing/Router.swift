//
//  Router.swift
//  NavigationApp
//
//  Created by David Tertre on 8/11/25.
//

import SwiftUI
import Combine



// ----- Map

enum MapMode: Hashable {
    case browse
    case navigating
}

struct MapSnapshot: Hashable {
    let mode: MapMode
    // let camera: MapCameraPosition
    // let selectionId: String?
    // let isSatellite: Bool
    // let activeRouteId: UUID?
}

@MainActor
final class MapSnapshotStack: ObservableObject {

    @Published private(set) var path = [MapSnapshot]()
    
    func push(_ snapshot: MapSnapshot) {
        path.append(snapshot)
    }
    
    func pop() { // chatget recomienda devolver el que quitas. Porque solo guarda estados anteriores.
        guard !path.isEmpty else { return }
        path.removeLast()
    }
    
    func pop(to snapshot: MapSnapshot) {
        guard let index = path.lastIndex(of: snapshot) else { return }
        path = Array(path.prefix(upTo: index + 1)) // doesnt include index upto -> this is why +1
    }
    
    func popAll() {
        path.removeAll()
    }
}

