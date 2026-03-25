//
//  LocationManager.swift
//  NavigationApp
//
//  Created by David Tertre on 5/11/25.
//

import CoreLocation
import Combine // to use Published

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {

    private let locationManager = CLLocationManager()
    
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var location: CLLocation?
    @Published var heading: CLLocationDirection?   // degrees: 0 = north, 90 = east
    
    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest // maximum accuracy
        // Optional: set the orientation used for heading calculations according to your UI
        self.locationManager.headingOrientation = .portrait
    }
    
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        self.authorizationStatus = manager.authorizationStatus
        
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            // Start location updates
            manager.startUpdatingLocation()
            
            // Start heading (bearing) updates
            if CLLocationManager.headingAvailable() {
                manager.startUpdatingHeading()
            } else {
                print("Heading is not available on this device.")
            }
        }
    }
    
    // Optional but important functions
    
    // Called when location/heading services fail
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("LocationManager did fail with error: \(error.localizedDescription)")
    }
    
    // Whether the system should show the heading calibration view when needed
    func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
        // Return true if you want to allow the calibration screen when iOS deems it necessary
        return true
    }
    
    // Heading updates
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
//        print(newHeading)
        // trueHeading can be -1 if not available; in that case, use magneticHeading
        let value = newHeading.trueHeading >= 0 ? newHeading.trueHeading : newHeading.magneticHeading
        // Normalize to [0, 360)
        let normalized = fmod((value + 360.0), 360.0)
        self.heading = normalized
        // print("Heading updated: \(normalized)º")
    }
    
    // Location updates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.location = locations.first
    }
}
