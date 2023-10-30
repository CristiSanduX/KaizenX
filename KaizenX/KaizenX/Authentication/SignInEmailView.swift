//
//  SignInEmailView.swift
//  KaizenX
//
//  Created by Cristi Sandu on 25.10.2023.
//

import SwiftUI

// Thread-ul principal este responsabil de UI și toate actualizările UI-ului trebuie să aibă loc pe acesta
@MainActor  // asigurăm să fie executat codul pe thread-ul principal
final class SignInEmailViewModel : ObservableObject {
    @Published var email = ""
    @Published var password = ""

    func signIn() {
        print("signIn - început")
        guard !email.isEmpty, !password.isEmpty else {
            print("E-mail sau parola lipsă")
            return
        }
        Task {
            do {
                let returnedUserData = try await AuthenticationManager.shared.createUser(email: email, password: password)
                print("Succes")
                print(returnedUserData)
            } catch {
                print("Error: \(error)")
            }
        }
        print("signIn - sfârșit")
    }
}

struct SignInEmailView: View {
    
    // Instanțiem clasa
    @StateObject private var viewModel = SignInEmailViewModel()
    var body: some View {
        VStack {
            TextField("Email...",text: $viewModel.email)
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(10)
            
            SecureField("Password...",text: $viewModel.password)
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(10)
            
            Button {
                viewModel.signIn()
            } label: {
                Text("Sign in")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 44)
                    .frame(maxWidth: .infinity)
                    .background(Color.darkRed)
                    .cornerRadius(12)
            }
            Spacer()
            
        }
        .padding()
        .navigationTitle("Sign in with email")
    }
}

#Preview {
    NavigationStack{
        SignInEmailView()
    }
}
