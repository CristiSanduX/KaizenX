//
//  KaizenXApp.swift
//  KaizenX
//
//  Created by Cristi Sandu on 25.10.2023.
//

// Punctul de intrare al aplicației
import SwiftUI
import FirebaseCore
import GoogleMaps


class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
      print("Configured Firebase")

    return true
  }
}

@main
struct KaizenXApp: App {
    
    // register app delegate for Firebase setup
      @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    init() {
        GMSServices.provideAPIKey("AIzaSyBqmV_qtdvxpUvYaf0JMPEOpT-6cUlzYnw")
    }
    
    var body: some Scene {
        WindowGroup {
            ContainerView()
        }
    }
}



