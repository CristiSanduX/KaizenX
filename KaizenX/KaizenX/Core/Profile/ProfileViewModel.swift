//
//  ProfileViewModel.swift
//  KaizenX
//
//  Created by Cristi Sandu on 26.11.2023.
//

import SwiftUI

/// ViewModel pentru ProfileView. Gestionează încărcarea și stocarea datelor profilului utilizatorului.
@MainActor
final class ProfileViewModel: ObservableObject {
    
    // Proprietatea Published stochează datele utilizatorului. Aceasta este accesibilă doar pentru citire în afara clasei.
    @Published private(set) var user: DBUser? = nil
    
    /// Încarcă datele utilizatorului curent autentificat.
    func loadCurrentUser() async throws {
        // Obține datele utilizatorului autentificat de la AuthenticationManager.
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        
        // Preia datele utilizatorului din Firestore folosind UserManager.
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
}
