//
//  GoogleMapsView.swift
//  KaizenX
//
//  Created by Cristi Sandu on 08.04.2024.
//


import SwiftUI
import GoogleMaps
import CoreLocation

struct GoogleMapsView: UIViewRepresentable {
    @ObservedObject var locationManager = LocationManager()

    
    func makeUIView(context: Self.Context) -> GMSMapView {
        let mapView = GMSMapView(frame: CGRect.zero)
        mapView.isMyLocationEnabled = true
        
        // Asigurați-vă că locația curentă este deja cunoscută înainte de a configura camera.
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
                
                // Căutăm sălile de sport și adăugăm markere pe hartă
                locationManager.searchNearbyGyms { gyms in
                    for gym in gyms {
                        if let geometry = gym["geometry"] as? [String: Any],
                           let locationDict = geometry["location"] as? [String: Any],
                           let lat = locationDict["lat"] as? CLLocationDegrees,
                           let lng = locationDict["lng"] as? CLLocationDegrees {
                            let marker = GMSMarker()
                            marker.position = CLLocationCoordinate2D(latitude: lat, longitude: lng)
                            marker.title = gym["name"] as? String
                            marker.snippet = gym["vicinity"] as? String
                            marker.map = mapView
                        }
                    }
                }
            }
        }
}

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
    
  
    
    func searchNearbyGyms(completion: @escaping ([[String: Any]]) -> Void) {
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
                    DispatchQueue.main.async {
                        completion(results)
                    }
                }
            } catch let error {
                print(error.localizedDescription)
            }
        }
        task.resume()
    }
}
