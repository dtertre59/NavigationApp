//
//  MapView.swift
//  NavigationApp
//
//  Created by David Tertre on 1/2/26.
//

import SwiftUI
import MapKit

struct MapView: View {
    
    @ObservedObject var vm: MapViewModel

    var body: some View {
        
        ZStack {
            MapReader { proxy in
                Map(position: $vm.cameraPosition, selection: $vm.selection) {

                    ForEach(vm.getPlaces()) { place in
                        // Markers
                        Marker(place.name, coordinate: place.coordinates)
                            .tint(.pink)    // default color
                            .tag(place)     // set selection var
                    }
                    
                    // User Location with heading cone
                    UserAnnotation()
//                    UserAnnotation(anchor: .center) { _ in
//                        ZStack {
//                            // Heading cone (sector) behind the puck
//                            if let heading = vm.locationManager.heading {
//                                // Configure cone appearance
//                                let spread: CGFloat = 50    // total cone angle in degrees (±25°)
//                                let radius: CGFloat = 80    // radius in points
//
//                                SectorCone(
//                                    headingDegrees: heading,
//                                    spreadDegrees: spread,
//                                    radius: radius
//                                )
//                                .fill(
//                                    AngularGradient(
//                                        gradient: Gradient(colors: [
//                                            Color.orange.opacity(0.18),
//                                            Color.orange.opacity(0.06)
//                                        ]),
//                                        center: .center
//                                    )
//                                )
//                                .overlay(
//                                    SectorCone(
//                                        headingDegrees: heading,
//                                        spreadDegrees: spread,
//                                        radius: radius
//                                    )
//                                    .stroke(Color.orange.opacity(0.35), lineWidth: 1)
//                                )
//                            }
//                            
//                            // Custom puck
//                            Circle()
//                                .fill(Color.orange)
//                                .frame(width: 18, height: 18)
//                                .overlay(
//                                    Circle()
//                                        .stroke(Color.white, lineWidth: 3)
//                                )
//                                .shadow(radius: 6)
//                        }
//                    }
                    
                    // Route if exists
                    if let polyline = vm.route?.polyline {
                        MapPolyline(polyline)
                            .stroke(.blue, lineWidth: 6)
                    }
                }
                
                // ----- Gesture to add places
                .gesture(
                    LongPressGesture(minimumDuration: 0.5)
                        .sequenced(before: DragGesture(minimumDistance: 0, coordinateSpace: .local))
                        .onEnded { value in
                            // Only when long-press completed and we get the initial drag
                            if case .second(true, let drag?) = value {
                                let point = drag.startLocation
                                if let coord = proxy.convert(point, from: .local) {
                                    Task {
                                        let location = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
                                        if let request = MKReverseGeocodingRequest(location: location) {
                                            do {
                                                let mapItems = try await request.mapItems
                                                let first = mapItems.first
                                                print(first?.address ?? "Unknown location")
                                                // Add place
                                                let place = Place(
                                                    name: first?.name ?? "Unknown name",
                                                    description: first?.address?.fullAddress ?? "Unknown location",
                                                    coordinates: CLLocationCoordinate2D(latitude: coord.latitude, longitude: coord.longitude)
                                                )
                                                vm.addPlace(place)
                                                // Optionally select the new place
                                                withAnimation {
                                                    vm.selection = place
                                                }
                                            } catch {
                                                print("Error reverse geocoding location: \(error)")
                                            }
                                        }
                                    }
                                }
                            }
                        }
                )
                
                // Selection changes
                .onChange(of: vm.selection) { oldSelection, newSelection in
                    print("Selection changed. Old \(oldSelection, default: "nil"), New \(newSelection, default: "nil")")
                }
                
//                .onMapCameraChange {
//                    // Si necesitas datos del contexto en plataformas nuevas,
//                    // puedes migrar a la versión con parámetro con #available.
//                    print("Map camera changed \(vm.cameraPosition.followsUserHeading, default: "nil")")
//                }
                
                // ----- Change camera position when the route changes (animated)
                .onChange(of: vm.route) { _, newRoute in
                    guard let route = newRoute else { return }
                    
                    let rect = route.polyline.boundingMapRect
                    var region = MKCoordinateRegion(rect)

                    // 1) Padding (zoom out) by expanding the span
                    region.span = MKCoordinateSpan(
                        latitudeDelta: region.span.latitudeDelta * 4,
                        longitudeDelta: region.span.longitudeDelta * 4
                    )

                    // 2) Vertical bias: move center to the SOUTH so content appears higher on screen
                    let bias: CLLocationDegrees = region.span.latitudeDelta * 0.20
                    region.center = CLLocationCoordinate2D(
                        latitude: region.center.latitude - bias,
                        longitude: region.center.longitude
                    )

                    // Animate the camera update
                    withAnimation(.easeInOut(duration: 0.65)) {
                        vm.cameraPosition = .region(region)
                    }
                }
                
                // ToolBar
                .toolbar {
                    // Lives in the navigation bar
                }
                // Deactivate/activate default controls
                .mapControlVisibility(.automatic)
                // Map style
                .mapStyle(vm.isSatellite ? .hybrid(elevation: .realistic) : .standard())
                // Map controls
                .mapControls {
                    MapUserLocationButton()
                    MapCompass()
                    MapPitchToggle()
                    // MapScaleView()
                }
                // Overlay
                .overlay(alignment: .topLeading) {
                    Button { vm.isSatellite.toggle()
                    } label: {
                        Image(systemName: vm.isSatellite ? "globe.americas.fill" : "map.fill")
                            .foregroundColor(.primary)
                            .frame(width: 46, height: 46)
                            .clipShape(.circle)
                    }
                    .glassEffect()
                    .padding()
                }
                // On appear
                .onAppear {
                    vm.locationManager.requestLocationPermission()
                }
            }
        }
    }
}


// ----- Previews ----- //

#Preview("Empty Map") {
    MapView(vm: .emptyPreview)
}

#Preview("Pinned Map") {
    MapView(vm: .withPinsPreview)
}

#Preview("Navigation Map") {
    MapView(vm: .navigationPreview)
}
