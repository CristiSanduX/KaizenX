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
    
    @StateObject private var viewModel = SignInEmailViewModel()  // ViewModel care gestionează logica de autentificare
    @Binding var showSignInView: Bool  // Binding pentru a controla afișarea acestui view
    
    var body: some View {
        VStack {
            // Iconița aplicației.
            Image("Logo1")
                .resizable()
                .scaledToFit()
                .frame(width: 125, height: 125)
                .padding(.bottom, 20)
            
            Spacer()
            
            VStack(spacing: 20) {
                // Câmpul de introducere a email-ului
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
                
                // Câmpurile pentru parolă și butonul pentru a arăta/ascunde parola
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
                
                // Butonul de autentificare
                Button {
                    Task {
                        await viewModel.signIn()
                        if viewModel.isSignedIn {
                            showSignInView = false
                        }
                    }
                } label: {
                    Text("Loghează-te")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .background(Color.darkRed)
                        .cornerRadius(10)
                }
                
                // Afișarea mesajului de eroare pentru autentificare
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.horizontal)
                }
                
                // Butonul pentru autentificare cu Google
                GoogleSignInButton(viewModel: GoogleSignInButtonViewModel(scheme: .light, style: .wide, state: .normal)) {
                    Task {
                        await viewModel.signInGoogle()
                        if viewModel.isSignedIn {
                            showSignInView = false
                        }
                    }
                }
                .frame(height: 44)
                .padding(.top, 10)
            }
            .padding()
            
            // Buton pentru resetarea parolei
            Button(action: {
                viewModel.showResetPasswordAlert = true
            }) {
                Text("Am uitat parola")
                    .foregroundColor(.darkRed)
            }
            .padding(.top, 10)
            .alert(isPresented: $viewModel.showResetPasswordAlert) {
                Alert(
                    title: Text("Resetare Parolă"),
                    message: Text("Introduceți adresa de e-mail pentru a primi instrucțiuni de resetare a parolei."),
                    primaryButton: .default(Text("Trimite")) {
                        Task {
                            await viewModel.resetPassword()
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
            
            Spacer()
            
            // Link pentru a naviga la ecranul de creare a unui nou cont
            NavigationLink(destination: SignUpView(showSignInView: $showSignInView)) {
                Text("Nu ai cont? Creează unul nou")
                    .foregroundColor(.darkRed)
            }
            .padding(.bottom, 20)
        }
        .padding()
        .background(Color.white.edgesIgnoringSafeArea(.all))
    }
}

#Preview {
    NavigationStack {
        SignInEmailView(showSignInView: .constant(true))
    }
}
