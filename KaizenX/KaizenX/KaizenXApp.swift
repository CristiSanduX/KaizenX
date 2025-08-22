//
//  KaizenXApp.swift
//  KaizenX
//
//  Created by Cristi Sandu pe 25.10.2023.
//

import SwiftUI
import FirebaseCore
import FirebaseAppCheck
import GoogleMaps

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        FirebaseApp.configure()
        print("Configured Firebase")
        
#if targetEnvironment(simulator)
        // Simulator: debug provider
        AppCheck.setAppCheckProviderFactory(
            { class DebugF: NSObject, AppCheckProviderFactory {
                func createProvider(with app: FirebaseApp) -> AppCheckProvider? { AppCheckDebugProvider(app: app) }
            }; return DebugF() }()
        )
#else
        // Device: DeviceCheck
        AppCheck.setAppCheckProviderFactory(
            { class DCFactory: NSObject, AppCheckProviderFactory {
                func createProvider(with app: FirebaseApp) -> AppCheckProvider? { DeviceCheckProvider(app: app) }
            }; return DCFactory() }()
        )
#endif
        
        
        
        
        return true
    }
}

/// Factory pentru DEVICE: App Attest (iOS 14+), altfel DeviceCheck.
final class MyAppCheckProviderFactory: NSObject, AppCheckProviderFactory {
    func createProvider(with app: FirebaseApp) -> AppCheckProvider? {
        if #available(iOS 14.0, *) {
            return AppAttestProvider(app: app)      // nu e nevoie de .isSupported
        } else {
            return DeviceCheckProvider(app: app)
        }
    }
}

/// Factory pentru SIMULATOR: Debug provider.
final class MyDebugAppCheckProviderFactory: NSObject, AppCheckProviderFactory {
    func createProvider(with app: FirebaseApp) -> AppCheckProvider? {
        return AppCheckDebugProvider(app: app)
    }
}

@main
struct KaizenXApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    init() {
        GMSServices.provideAPIKey("AIzaSyBqmV_qtdvxpUvYaf0JMPEOpT-6cUlzYnw")
    }
    
    var body: some Scene {
        WindowGroup { ContainerView() }
    }
}
