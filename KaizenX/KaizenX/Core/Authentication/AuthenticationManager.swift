//
//  AuthenticationManager.swift
//  KaizenX
//
//  Created de Cristi Sandu on 27.10.2023.
//

import Foundation
import FirebaseAuth

/// Un model simplificat pentru a reprezenta rezultatul autentificării Firebase
struct AuthDataResultModel {
    let uid: String
    let email: String?
    let photoURL: String?
    
    init(user: User) {
        self.uid = user.uid
        self.email = user.email
        self.photoURL = user.photoURL?.absoluteString
    }
}

/// Enumerația opțiunilor de autentificare suportate
enum AuthProviderOption: String {
    case email = "password"
    case google = "google.com"
}

/// Managerul de autentificare centralizează logica de autentificare Firebase
final class AuthenticationManager {
    static let shared = AuthenticationManager()
    private init() { }
    
    /// Returnează utilizatorul autentificat curent
    func getAuthenticatedUser() throws -> AuthDataResultModel {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        return AuthDataResultModel(user: user)
    }
    
    /// Returnează lista de furnizori de autentificare asociați cu utilizatorul curent
    func getProviders() throws -> [AuthProviderOption] {
        guard let providerData = Auth.auth().currentUser?.providerData else {
            throw URLError(.badServerResponse)
        }
        
        var providers: [AuthProviderOption] = []
        for provider in providerData {
            if let option = AuthProviderOption(rawValue: provider.providerID) {
                providers.append(option)
            } else {
                assertionFailure("Provider option not found: \(provider.providerID)")
            }
        }
        return providers
    }
    
    /// Deconectează utilizatorul curent
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    /// Șterge contul utilizatorului curent
    func delete() async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badURL)
        }
        try await user.delete()
    }
    
    /// Trimite un email de verificare utilizatorului curent
    func sendEmailVerification() async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        try await user.sendEmailVerification()
    }
}

// SIGN IN WITH EMAIL
extension AuthenticationManager {
    @discardableResult // valoarea returnată de funcție poate fi ignorată fără a primi warning
    /// Creează un utilizator nou și returnează datele acestuia
    func createUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    @discardableResult
    /// Autentifică un utilizator și returnează datele acestuia
    func signInUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    /// Trimite o cerere de resetare a parolei la e-mailul specificat
    func resetPassword(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }

    /// Actualizează parola utilizatorului curent
    func updatePassword(password: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        try await user.updatePassword(to: password)
    }
    
    /// Trimite un email de verificare înainte de actualizarea e-mailului utilizatorului curent
    func sendEmailVerification(beforeUpdatingEmail email: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        try await user.sendEmailVerification(beforeUpdatingEmail: email)
    }
}

// SIGN IN WITH GOOGLE
extension AuthenticationManager {
    @discardableResult
    /// Autentifică un utilizator cu credențialele Google și returnează datele acestuia
    func signInWithGoogle(tokens: GoogleSignInResultModel) async throws -> AuthDataResultModel {
        let credential = GoogleAuthProvider.credential(withIDToken: tokens.idToken, accessToken: tokens.accessToken)
        return try await signIn(credential: credential)
    }
    
    func signIn(credential: AuthCredential) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signIn(with: credential)
        return AuthDataResultModel(user: authDataResult.user)
    }
}
