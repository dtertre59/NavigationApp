//
//  MapViewModel.swift
//  NavigationApp
//
//  Created by David Tertre on 8/11/25.
//

import SwiftUI
import Combine
import MapKit


@MainActor
final class MapViewModel: ObservableObject {
    // UI state
    @Published var isSatellite: Bool = false
    @Published var cameraPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    
    // My location
    @Published var locationManager = LocationManager()
    
    // Repository
    @Published private(set) var places: [Place] = []
    private let placesRepository: PlacesRepository
    
    // Delete ?
    //    @Published var showInfo: Bool = true
    @Published var selection: Place? = nil
    //    @Published var showActions: Bool = false
    
    
    // ----- Route -----
    
    @Published var route: MKRoute?
    @Published var destination: CLLocationCoordinate2D?
    
    
    init(placesRepository: PlacesRepository) {
        self.placesRepository = placesRepository
        placesRepository.placesPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: &$places)
    }
    
    func toggleSatellite() {
        isSatellite.toggle()
    }
    
    func getPlaces() -> [Place] {
        return placesRepository.getPlaces()
    }
    
    func addPlace(_ place: Place) {
        placesRepository.addPlace(place)
        
    }
    
    // ----- Route -----
    
    // TODO: Dont relolad route when is setting the same destination
    func setDestination(_ destination: CLLocationCoordinate2D?) {
        self.destination = destination
        guard let destination else {
            self.route = nil
            return
        }
        Task { await calculateRoute(to: destination) }
    }
    
    func calculateRoute(to destination: CLLocationCoordinate2D) async {
        
        // 1. validate location
        guard let currentLocation = locationManager.location else {
            return
        }
        
        // 2. Configure request
        let request = MKDirections.Request()
        
        // iOS 26+ preferred: construct MKMapItem directly from CLLocation
        let sourceItem = MKMapItem(location: currentLocation, address: nil)
        let destinationLocation = CLLocation(latitude: destination.latitude, longitude: destination.longitude)
        let destinationItem = MKMapItem(location: destinationLocation, address: nil)
        
        request.source = sourceItem
        request.destination = destinationItem
        request.transportType = .walking
        
        // 3. Execute Async/Await
        let directions = MKDirections(request: request)
        do {
            let response = try await directions.calculate()
            guard let bestRoute = response.routes.first else {
                print("No routes found")
                self.route = nil
                return
            }
            self.route = bestRoute
        } catch {
            print("Error calculating directions: \(error)")
            self.route = nil
        }
    }
    
    // ----- Camera control (Coordinator decides the parameters) -----
    func setCamera(
        center: CLLocationCoordinate2D,
        distance: CLLocationDistance,
        pitch: CGFloat,
        heading: CLLocationDirection,
        animated: Bool = true,
        animation: Animation = .easeInOut(duration: 0.6)
    ) {
        let camera = MapCamera(
            centerCoordinate: center,
            distance: distance,
            heading: heading,
            pitch: pitch
        )
        if animated {
            withAnimation(animation) {
                self.cameraPosition = .camera(camera)
            }
        } else {
            self.cameraPosition = .camera(camera)
        }
    }
}



#if DEBUG

extension MapViewModel {
    
    @discardableResult
    func setPreviewCenter(
            _ center: CLLocationCoordinate2D,
            span: MKCoordinateSpan = .init(latitudeDelta: 0.05, longitudeDelta: 0.05)
        ) -> MapViewModel {
            self.cameraPosition = .region(
                MKCoordinateRegion(center: center, span: span)
            )
            return self
        }
    
    static var emptyPreview: MapViewModel {
        .init(placesRepository: PlacesRepositoryMock(initialPlaces: []))
    }
    
    @discardableResult
    func setPreviewCamera(
        center: CLLocationCoordinate2D,
        distance: CLLocationDistance = 700,   // zoom (más pequeño = más cerca)
        heading: CLLocationDirection = 0,     // rotación en grados
        pitch: CGFloat = 65                  // inclinación 0...90
    ) -> MapViewModel {
        cameraPosition = .camera(
            MapCamera(
                centerCoordinate: center,
                distance: distance,
                heading: heading,
                pitch: pitch
            )
        )
        return self
    }


    static var withPinsPreview: MapViewModel {
        .init(placesRepository: PlacesRepositoryMock(initialPlaces: [
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
        ])).setPreviewCenter(.init(latitude: 40.5637, longitude: -4.0180))
    }
    
    static var navigationPreview: MapViewModel {
        let place = Place(
                    // id: UUID(),  // si tu Place lo exige
                    name: "Parque El Pozo",
                    description: "Pequeño parque urbano con zona infantil, bancos y árboles, ideal para pasear o descansar en el centro de Colmenarejo.",
                    coordinates: CLLocationCoordinate2D(latitude: 40.563072, longitude: -4.017154)
                )

        let vm = MapViewModel(
            placesRepository: PlacesRepositoryMock(initialPlaces: [place])
        )

        vm.isSatellite = true

        // Si quieres que “apunte” al icono, el centro = coordenadas del place
        vm.setPreviewCamera(
            center: place.coordinates,
            distance: 650,     // prueba 400–1200 según zoom deseado
            heading: 25,       // gira un poquito para que se vea “pro”
            pitch: 90          // inclinación fuerte (0 plano, 90 casi vertical)
        )

        // Opcional: que parezca seleccionado (si tu mapa usa selection)
        vm.selection = place

        return vm
    }
}

#endif
