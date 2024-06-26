//
//  SettingsView.swift
//  KaizenX
//
//  Created by Cristi Sandu pe 30.10.2023.
//

import SwiftUI

/// SettingsView reprezintă ecranul de setări unde utilizatorii pot modifica detaliile contului și se pot deconecta
struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @Binding var showSignInView: Bool  // Această variabilă decide dacă ecranul de autentificare trebuie afișat.
    
    var body: some View {
        List {
            Button("Deconectare") {
                Task {
                    do {
                        try viewModel.signOut()
                        showSignInView = true  // Deconectează utilizatorul și afișează ecranul de autentificare.
                    } catch {
                        print(error)
                    }
                }
            }
            
            Button(role: .destructive) {
                Task {
                    do {
                        try await viewModel.deleteAccount()
                        showSignInView = true  // Șterge contul și afișează ecranul de autentificare.
                    } catch {
                        print(error)
                    }
                }
            } label: {
                Text("Ștergere cont")
            }
            
            if viewModel.authProviders.contains(.email) {
                
                Section {
                    Button("Resetare parolă") {
                        Task {
                            do {
                                try await viewModel.resetPassword()
                                print("Parolă resetată!")
                            } catch {
                                print(error)
                            }
                        }
                    }
                    
                    Button("Schimbare parolă") {
                        Task {
                            do {
                                try await viewModel.updatePassword()
                                print("Parolă schimbată!")
                            } catch {
                                print(error)
                            }
                        }
                    }
                    Button("Trimite verificare e-mail pentru schimbare") {
                        Task {
                            do {
                                try await viewModel.sendEmailVerificationBeforeUpdating()
                                print("Email de verificare trimis pentru schimbare!")
                            } catch {
                                print(error)
                            }
                        }
                    }
                } header: {
                    Text("Funcții e-mail")
                }
            }
        }
        .onAppear {
            viewModel.loadAuthProviders()  // Încarcă furnizorii de autentificare la apariția view-ului.
        }
        .navigationTitle("Setări cont")
    }
}

#Preview {
    NavigationStack {
        SettingsView(showSignInView: .constant(false))
    }
}
