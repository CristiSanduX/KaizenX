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
    @Published var isPasswordVisible = false


    func signUp() async throws{
        print("signUp - început")
        guard !email.isEmpty, !password.isEmpty else {
            print("E-mail sau parola lipsă")
            return
        }
        try await AuthenticationManager.shared.createUser(email: email, password: password)
    }
    
    func signIn() async throws{
        print("signIn - început")
        guard !email.isEmpty, !password.isEmpty else {
            print("E-mail sau parola lipsă")
            return
        }
        try await AuthenticationManager.shared.signInUser(email: email, password: password)
    }
}

struct SignInEmailView: View {
    
    // Instanțiem clasa
    @StateObject private var viewModel = SignInEmailViewModel()
    @Binding var showSignInView: Bool
    var body: some View {
        VStack {
            TextField("Email...",text: $viewModel.email)
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(10)
            
            HStack {
                if viewModel.isPasswordVisible {
                    TextField("Password...", text: $viewModel.password)
                } else {
                    SecureField("Password...", text: $viewModel.password)
                        
                }
                
                Button(action: {
                    viewModel.isPasswordVisible.toggle()
                }, label: {
                    Image(systemName: viewModel.isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                        .foregroundColor(.gray)
                })
            }
            .padding()
            .background(Color.gray.opacity(0.4))
            .cornerRadius(10)

            
            Button {
                Task {
                    do {
                        try await viewModel.signIn()
                        showSignInView = false
                        return
                    } catch {
                        print(error)
                    }
                }
            } label: {
                Text("Sign in")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 44)
                    .frame(maxWidth: .infinity)
                    .background(Color.darkRed)
                    .cornerRadius(12)
            }
            NavigationLink(destination: SignUpView()) {
                            Text("Nu ai cont? Creează unul nou")
                        }
                        .padding(.top, 20)
            Spacer()
            
        }
        .padding()
        .navigationTitle("Sign in with email")
    }
}

#Preview {
    NavigationStack{
        SignInEmailView(showSignInView: .constant(false))
    }
}
