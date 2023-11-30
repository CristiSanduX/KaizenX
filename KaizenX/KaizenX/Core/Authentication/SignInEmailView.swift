//
//  SignInEmailView.swift
//  KaizenX
//
//  Created by Cristi Sandu on 25.10.2023.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

// View-ul care gestionează autentificarea utilizatorilor
struct SignInEmailView: View {
    
    @StateObject private var viewModel = SignInEmailViewModel()  // ViewModel care gestionează logica de autentificare.
    @Binding var showSignInView: Bool
    
    var body: some View {
        VStack {
            // Câmpul de introducere a email-ului.
            TextField("Email...",text: $viewModel.email)
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(10)
            
            // Câmpurile pentru parolă și butonul pentru a arăta/ascunde parola.
            HStack {
                if viewModel.isPasswordVisible {
                    TextField("Parolă...", text: $viewModel.password)
                } else {
                    SecureField("Parolă...", text: $viewModel.password)
                }
                
                // Butonul pentru a comuta vizibilitatea parolei.
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
            
            // Butonul de autentificare.
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
                Text("Loghează-te")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 44)
                    .frame(maxWidth: .infinity)
                    .background(Color.darkRed)
                    .cornerRadius(12)
            }
            
            // Butonul pentru autentificare cu Google.
            GoogleSignInButton(viewModel: GoogleSignInButtonViewModel(scheme: .dark, style: .wide, state: .normal)) {
                Task {
                    do {
                        try await viewModel.signInGoogle()
                        showSignInView = false
                    } catch {
                        print(error)
                    }
                }
            }
            
            // Link pentru a naviga la ecranul de creare a unui nou cont.
            NavigationLink(destination: SignUpView(showSignInView: $showSignInView)) {
                Text("Nu ai cont? Creează unul nou")
            }
            .padding(.top, 20)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Logare")
    }
}

#Preview {
    NavigationStack{
        SignInEmailView(showSignInView: .constant(true))
    }
}
