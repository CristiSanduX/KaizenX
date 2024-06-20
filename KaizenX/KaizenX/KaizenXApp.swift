//
//  KaizenXApp.swift
//  KaizenX
//
//  Created by Cristi Sandu pe 25.10.2023.
//

// Punctul de intrare al aplicației
import SwiftUI
import FirebaseCore
import GoogleMaps

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Configurare Firebase
        FirebaseApp.configure()
        print("Configured Firebase")
        
        // Alte configurări suplimentare dacă sunt necesare
        
        return true
    }
}

@main
struct KaizenXApp: App {
    
    // Înregistrare AppDelegate pentru configurarea Firebase
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    init() {
        // Configurare Google Maps cu cheia API
        GMSServices.provideAPIKey("AIzaSyBqmV_qtdvxpUvYaf0JMPEOpT-6cUlzYnw")
    }
    
    var body: some Scene {
        WindowGroup {
            ContainerView()
        }
    }
}
