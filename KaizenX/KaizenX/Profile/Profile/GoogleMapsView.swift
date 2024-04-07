//
//  GoogleMapsView.swift
//  KaizenX
//
//  Created by Cristi Sandu on 08.04.2024.
//

import SwiftUI
import GoogleMaps

struct GoogleMapsView: UIViewRepresentable {
    
    func makeUIView(context: Self.Context) -> GMSMapView {
        let camera = GMSCameraPosition.camera(withLatitude: -33.8688, longitude: 151.2093, zoom: 6.0)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        return mapView
    }
    
    func updateUIView(_ uiView: GMSMapView, context: Context) {
    }
}

#Preview {
    GoogleMapsView()
}
