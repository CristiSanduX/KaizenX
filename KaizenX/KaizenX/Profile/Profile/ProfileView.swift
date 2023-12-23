//
//  ProfileView.swift
//  KaizenX
//
//  Created by Cristi Sandu on 22.11.2023.
//

import SwiftUI

/// Afișează profilul utilizatorului curent, permițând actualizarea imaginii de profil și vizualizarea datelor de autentificare.
struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @Binding var showSignInview: Bool
    
    // Stări pentru afișarea selectorului de imagini și stocarea imaginii selectate.
    @State private var isImagePickerPresented = false
    @State private var selectedImage: UIImage?
    
    
    
    var body: some View {
        List {
            if let user = viewModel.user {
                // Secțiune pentru afișarea detaliilor utilizatorului
                ZStack(alignment: .bottomTrailing) {
                    if let photoURLString = user.photoURL, let photoURL = URL(string: photoURLString) {
                        AsyncImage(url: photoURL) { image in
                            image.resizable()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                    } else {
                        // Adaugă o imagine placeholder dacă nu există o imagine de profil.
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .padding()
                    }
                    
                    // Butonul de editare cu semnul „plus”.
                    Button(action: {
                        isImagePickerPresented = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.white)
                            .background(Color.accentColor)
                            .clipShape(Circle())
                    }
                    .padding(10)  // Asigură spațiu în jurul butonului.
                }
                .padding()
                
                
                Text("ID: \(user.userId)")
                
                if let email = user.email {
                    Text("E-mail: \(email)")
                }
                
                Text("Pași astăzi: \(viewModel.steps, specifier: "%.0f")")
                    .onAppear {
                        viewModel.loadSteps()
                    }
                
               
            }
        }

        .onAppear {
            Task {
                try? await viewModel.loadCurrentUser()

            }
        }
        .sheet(isPresented: $isImagePickerPresented) {
            PhotoPicker(selectedImage: $selectedImage) {
                guard let selectedImage = selectedImage else { return }
                Task {
                    try? await viewModel.uploadImageToStorage(selectedImage)
                }
            }
        }
        .navigationTitle("Profil")
        .toolbar {
            // Adaugă un buton pentru navigare către setări.
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    SettingsView(showSignInview: $showSignInview)
                } label: {
                    Image(systemName: "gear")
                        .font(.headline)
                }
            }
        }
    }
}



#Preview {
    NavigationStack{
        ProfileView(showSignInview: .constant(false))
    }
}




