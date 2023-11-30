//
//  Utilities.swift
//  KaizenX
//
//  Created by Cristi Sandu on 07.11.2023.
//

import Foundation
import UIKit

/// Clasa `Utilities` oferă funcții utilitare generale folosite în întreaga aplicație.
final class Utilities {
    /// Instanță singleton pentru accesul la funcțiile utilitare.
    static let shared  = Utilities()
    
    /// Constructor privat pentru a preveni inițializarea multiplă și a asigura un singur punct de acces.
    private init() {}
    
    /// Găsește și returnează `UIViewController`-ul cel mai în vârf din ierarhia de view controllers.
    /// Această funcție este recursivă și parcurge navigația controllerelor pentru a găsi cel activ.
    /// - Parameter controller: Controllerul de pornire pentru căutare, dacă este nil, începe de la root.
    /// - Returns: `UIViewController`-ul activ, sau nil dacă nu este găsit niciunul.
    @MainActor
    func topViewController(controller: UIViewController? = nil) -> UIViewController? {
        
        let controller = controller ?? UIApplication.shared.keyWindow?.rootViewController
        
        // Parcurge recursiv UINavigationController dacă este prezent.
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        
        // Parcurge UITabBarController pentru a găsi tab-ul activ.
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        
        // Verifică și returnează controller-ul prezentat, dacă există.
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        
        return controller
    }
}
