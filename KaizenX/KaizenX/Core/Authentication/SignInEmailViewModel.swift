//
//  SignInEmailViewModel.swift
//  KaizenX
//
//  Created by Cristi Sandu on 22.11.2023.
//

import Foundation

// Thread-ul principal este responsabil de UI și toate actualizările UI-ului trebuie să aibă loc pe acesta
@MainActor  // asigurăm să fie executat codul pe thread-ul principal
final class SignInEmailViewModel : ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isPasswordVisible = false
    
    func signIn() async throws{
        print("signIn - început")
        guard !email.isEmpty, !password.isEmpty else {
            print("E-mail sau parola lipsă")
            return
        }
        try await AuthenticationManager.shared.signInUser(email: email, password: password)
    }
    
    func signInGoogle() async throws{
        let helper = SignInGoogleHelper()
        let tokens = try await helper.signIn()
        try await AuthenticationManager.shared.signInWithGoogle(tokens: tokens)
    }
}
