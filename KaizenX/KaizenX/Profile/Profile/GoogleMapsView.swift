//
//  GoogleMapsView.swift
//  KaizenX
//
//  Created by Cristi Sandu on 08.04.2024.
//

import SwiftUI
import GoogleMaps

struct GoogleMapsView: UIViewRepresentable {
    @ObservedObject var locationManager = LocationManager()
    
    func makeUIView(context: Self.Context) -> GMSMapView {
        let mapView = GMSMapView(frame: CGRect.zero)
        mapView.isMyLocationEnabled = true  // Afișează locația curentă pe hartă
        return mapView
    }
    
    func updateUIView(_ mapView: GMSMapView, context: Context) {
        if let location = locationManager.lastKnownLocation {
            let camera = GMSCameraPosition.camera(withTarget: location.coordinate, zoom: 15)
            mapView.animate(to: camera)
        }
    }
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var lastKnownLocation: CLLocation?

    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastKnownLocation = locations.last
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Nu s-a putut obține locația: \(error.localizedDescription)")
    }
}
