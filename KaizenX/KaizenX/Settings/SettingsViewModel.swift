//
//  SettingsViewModel.swift
//  KaizenX
//
//  Created by Cristi Sandu on 22.11.2023.
//

import Foundation

/// ViewModel care gestionează logica din spatele ecranului de setări, permițând utilizatorului să efectueze acțiuni legate de contul său.
@MainActor
final class SettingsViewModel: ObservableObject {
    
    // Lista de opțiuni pentru metodele de autentificare disponibile.
    @Published var authProviders: [AuthProviderOption] = []
    
    /// Încarcă metodele de autentificare disponibile pentru utilizator.
    func loadAuthProviders() {
        if let providers = try? AuthenticationManager.shared.getProviders() {
            authProviders = providers
        }
    }
    
    /// Închide sesiunea utilizatorului curent.
    func signOut() throws{
        try AuthenticationManager.shared.signOut()
    }
    
    /// Șterge contul utilizatorului curent.
    func deleteAccount() async throws{
        try await AuthenticationManager.shared.delete()
    }
    
    /// Inițiază procesul de resetare a parolei pentru utilizator.
    func resetPassword() async throws{
        let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
        
        guard let email = authUser.email else{
            throw URLError(.fileDoesNotExist)
        }
        try await AuthenticationManager.shared.resetPassword(email: email)
    }
    
    /// Actualizează emailul utilizatorului curent.
    func updateEmail() async throws {
        // To do: emailul ar trebui să fie primit ca parametru sau editabil prin UI.
        let email = "cristisandu@csx.ro"
        try await AuthenticationManager.shared.updateEmail(email: email)
    }
    
    func updatePassword() async throws {
        // To do: parola ar trebui să fie primită ca parametru sau editabilă prin UI.
        let password = "TestParola1"
        try await AuthenticationManager.shared.updatePassword(password: password)
    }
}
