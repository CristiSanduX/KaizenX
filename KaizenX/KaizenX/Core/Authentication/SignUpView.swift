//
//  SignUpView.swift
//  KaizenX
//
//  Created de Cristi Sandu on 02.11.2023.
//

import SwiftUI

/// Ecranul de înregistrare care permite utilizatorilor să creeze un cont nou
struct SignUpView: View {
    @StateObject private var viewModel = SignUpViewModel()
    @Binding var showSignInView: Bool
    @State private var showCheckEmailView = false  // Adăugat pentru a controla afișarea ecranului de verificare email

    var body: some View {
        VStack {
            // Iconița aplicației
            Image("Logo1")
                .resizable()
                .scaledToFit()
                .frame(width: 125, height: 125)
                .padding(.bottom, 20)
            
            Spacer()
            
            VStack(spacing: 20) {
                // Câmpul pentru introducerea email-ului
                TextField("E-mail...", text: $viewModel.email)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .foregroundColor(.black)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .onChange(of: viewModel.email) {
                        viewModel.validateEmail()
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(viewModel.isEmailValid ? Color.clear : Color.red, lineWidth: 2)
                    )
                
                // Mesaj de eroare pentru email
                if !viewModel.isEmailValid {
                    Text("E-mail invalid.")
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.horizontal)
                }
                
                // Câmpurile pentru introducerea și confirmarea parolei
                HStack {
                    if viewModel.isPasswordVisible {
                        TextField("Parolă...", text: $viewModel.password)
                    } else {
                        SecureField("Parolă...", text: $viewModel.password)
                    }
                    
                    // Butonul pentru a comuta vizibilitatea parolei
                    Button(action: {
                        viewModel.isPasswordVisible.toggle()
                    }, label: {
                        Image(systemName: viewModel.isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                            .foregroundColor(.gray)
                    })
                }
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .foregroundColor(.black)
                .onChange(of: viewModel.password) {
                    viewModel.validatePassword()
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(viewModel.isPasswordValid ? Color.clear : Color.red, lineWidth: 2)
                )
                
                // Mesaj de eroare pentru parolă
                if !viewModel.isPasswordValid {
                    Text("Parola trebuie să aibă cel puțin 6 caractere.")
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.horizontal)
                }
                
                // Câmpul pentru confirmarea parolei
                SecureField("Confirmă parola...", text: $viewModel.confirmPassword)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .foregroundColor(.black)
                    .onChange(of: viewModel.confirmPassword) {
                        viewModel.validateConfirmPassword()
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(viewModel.doPasswordsMatch ? Color.clear : Color.red, lineWidth: 2)
                    )
                
                // Mesaj de eroare pentru confirmarea parolei
                if !viewModel.doPasswordsMatch {
                    Text("Parolele nu coincid.")
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.horizontal)
                }
                
                // Butonul de înregistrare
                Button {
                    Task {
                        let signUpSuccess = await viewModel.signUp()
                        if signUpSuccess {
                            showCheckEmailView = true
                        }
                    }
                } label: {
                    Text("Creează cont")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .background(Color.darkRed)
                        .cornerRadius(10)
                }
                
                // Afișarea mesajului de eroare pentru înregistrare
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.horizontal)
                }
            }
            .padding()
            
            Spacer()
        }
        .padding()
        .background(Color.white.edgesIgnoringSafeArea(.all))
        .navigationDestination(isPresented: $showCheckEmailView) {
            CheckEmailVerificationView(showSignInView: $showSignInView)
        }
    }
}

#Preview {
    NavigationStack {
        SignUpView(showSignInView: .constant(true))
    }
}
