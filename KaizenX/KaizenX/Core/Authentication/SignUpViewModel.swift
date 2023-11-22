//
//  SignUpViewModel.swift
//  KaizenX
//
//  Created by Cristi Sandu on 22.11.2023.
//

import Foundation

@MainActor
final class SignUpViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    
    func signUp() async -> Bool {
        print("signUp - început")
        guard !email.isEmpty, !password.isEmpty, password == confirmPassword else {
            print("E-mail, parola lipsă sau parolele nu c oincid.")
            return false
        }
        do {
            try await AuthenticationManager.shared.createUser(email: email, password: password)
            return true
        } catch {
            print(error)
            return false
        }
    }
}
