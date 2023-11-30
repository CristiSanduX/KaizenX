//
//  SignInGoogleHelper.swift
//  KaizenX
//
//  Created by Cristi Sandu on 12.11.2023.
//

import Foundation
import GoogleSignIn
import GoogleSignInSwift

/// Model pentru stocarea rezultatelor autentificării cu Google.
struct GoogleSignInResultModel {
    let idToken: String
    let accessToken: String
    let name: String?
    let email: String?
}

/// Clasa ajutătoare pentru autentificarea cu Google.
final class SignInGoogleHelper {
    
    /// Inițiază și gestionează procesul de autentificare cu Google.
    @MainActor
    func signIn() async throws -> GoogleSignInResultModel{
        guard let topVC = Utilities.shared.topViewController() else {
            throw URLError(.cannotFindHost)
        }
        // Realizează autentificarea și obține rezultatele.
        let gidSignInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: topVC)
        
        // Extragere și validare token-uri de la rezultatele autentificării.
        guard let idToken = gidSignInResult.user.idToken?.tokenString else {
            throw URLError(.badServerResponse)
        }
        let accessToken = gidSignInResult.user.accessToken.tokenString
        let name = gidSignInResult.user.profile?.name
        let email = gidSignInResult.user.profile?.email
        
        // Crează și returnează modelul cu rezultatele autentificării.
        let tokens = GoogleSignInResultModel(idToken: idToken, accessToken: accessToken, name: name, email: email)
        return tokens
    }
}


