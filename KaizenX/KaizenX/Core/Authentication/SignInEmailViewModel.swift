//
//  SignInEmailViewModel.swift
//  KaizenX
//
//  Created by Cristi Sandu on 22.11.2023.
//

import Foundation

/// ViewModel-ul pentru SignInEmailView, gestionează logica de autentificare prin email și Google.
@MainActor  // Asigură că actualizările UI se fac pe thread-ul principal.
final class SignInEmailViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isPasswordVisible = false  // Controlează vizibilitatea textului în câmpul parolei.
    
    /// Încearcă să autentifice utilizatorul cu email-ul și parola introduse.
    func signIn() async throws{
        print("signIn - început")
        guard !email.isEmpty, !password.isEmpty else {
            print("E-mail sau parola lipsă")
            return
        }
        try await AuthenticationManager.shared.signInUser(email: email, password: password)
    }
    
    /// Încearcă să autentifice utilizatorul prin Google și să creeze un nou utilizator în baza de date, dacă este necesar.
    func signInGoogle() async throws{
        let helper = SignInGoogleHelper()
        let tokens = try await helper.signIn()
        let authDataResult = try await AuthenticationManager.shared.signInWithGoogle(tokens: tokens)
        try await UserManager.shared.createNewUser(auth: authDataResult)
    }
}
