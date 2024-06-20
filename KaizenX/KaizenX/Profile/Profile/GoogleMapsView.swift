//
//  GoogleMapsView.swift
//  KaizenX
//
//  Created by Cristi Sandu on 08.04.2024.
//

import SwiftUI
import GoogleMaps
import CoreLocation
import MapKit

struct Gym: Identifiable {
    let id = UUID()
    let name: String
    let vicinity: String
    let latitude: CLLocationDegrees
    let longitude: CLLocationDegrees
}

/// View-ul care încorporează o hartă Google Maps pentru a afișa sălile de sport din apropiere.
struct GoogleMapsView: UIViewRepresentable {
    @ObservedObject var locationManager: LocationManager
    
    func makeUIView(context: Self.Context) -> GMSMapView {
        let mapView = GMSMapView()
        mapView.isMyLocationEnabled = true
        mapView.delegate = context.coordinator
        
        // Configurează camera dacă locația curentă este cunoscută.
        if let location = locationManager.lastKnownLocation {
            let camera = GMSCameraPosition.camera(withTarget: location.coordinate, zoom: 13)
            mapView.camera = camera
        }
        
        return mapView
    }
    
    func updateUIView(_ mapView: GMSMapView, context: Context) {
        if let location = locationManager.lastKnownLocation {
            let camera = GMSCameraPosition.camera(withTarget: location.coordinate, zoom: 13)
            mapView.animate(to: camera)
            
            // Căutăm sălile de sport și adăugăm markere pe hartă.
            locationManager.searchNearbyGyms { gyms in
                for gym in gyms {
                    let marker = GMSMarker()
                    marker.position = CLLocationCoordinate2D(latitude: gym.latitude, longitude: gym.longitude)
                    marker.title = gym.name
                    marker.snippet = gym.vicinity
                    marker.userData = gym // Store the gym data in the marker
                    marker.map = mapView
                }
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    class Coordinator: NSObject, GMSMapViewDelegate {
        var parent: GoogleMapsView
        
        init(_ parent: GoogleMapsView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
            if let gym = marker.userData as? Gym {
                let alert = UIAlertController(title: gym.name, message: gym.vicinity, preferredStyle: .alert)
                
                let googleMapsAction = UIAlertAction(title: "Deschide în Google Maps", style: .default) { _ in
                    if let url = URL(string: "comgooglemaps://?q=\(gym.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&center=\(gym.latitude),\(gym.longitude)") {
                        UIApplication.shared.open(url)
                    }
                }
                
                let appleMapsAction = UIAlertAction(title: "Deschide în Apple Maps", style: .default) { _ in
                    let coordinate = CLLocationCoordinate2D(latitude: gym.latitude, longitude: gym.longitude)
                    let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
                    mapItem.name = gym.name
                    mapItem.openInMaps()
                }
                
                alert.addAction(googleMapsAction)
                alert.addAction(appleMapsAction)
                alert.addAction(UIAlertAction(title: "Anulează", style: .cancel))
                
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootViewController = windowScene.windows.first?.rootViewController {
                    rootViewController.present(alert, animated: true)
                }
            }
            return true
        }
    }
}

/// Managerul de locație care gestionează actualizarea locației și căutarea sălilor de sport din apropiere.
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var lastKnownLocation: CLLocation?
    
    let googlePlacesAPIKey = "AIzaSyBqmV_qtdvxpUvYaf0JMPEOpT-6cUlzYnw"
    let googlePlacesURL = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?"
    
    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastKnownLocation = locations.last
    }
    
    /// Caută sălile de sport din apropiere utilizând API-ul Google Places.
    func searchNearbyGyms(completion: @escaping ([Gym]) -> Void) {
        guard let location = lastKnownLocation else { return }
        let locationStr = "\(location.coordinate.latitude),\(location.coordinate.longitude)"
        let radius = 5000
        let type = "gym"
        let urlStr = "\(googlePlacesURL)location=\(locationStr)&radius=\(radius)&type=\(type)&key=\(googlePlacesAPIKey)"
        
        guard let url = URL(string: urlStr) else { return }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "Unknown error")
                return
            }
            
            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let results = jsonResponse["results"] as? [[String: Any]] {
                    var gyms: [Gym] = []
                    for result in results {
                        if let name = result["name"] as? String,
                           let vicinity = result["vicinity"] as? String,
                           let geometry = result["geometry"] as? [String: Any],
                           let location = geometry["location"] as? [String: Any],
                           let lat = location["lat"] as? CLLocationDegrees,
                           let lng = location["lng"] as? CLLocationDegrees {
                            let gym = Gym(name: name, vicinity: vicinity, latitude: lat, longitude: lng)
                            gyms.append(gym)
                        }
                    }
                    DispatchQueue.main.async {
                        completion(gyms)
                    }
                }
            } catch let error {
                print(error.localizedDescription)
            }
        }
        task.resume()
    }
}
