//
//  ProfileView.swift
//  KaizenX
//
//  Created by Cristi Sandu on 22.11.2023.
//

import SwiftUI

/// View-ul pentru profilul utilizatorului. Afișează informații despre utilizatorul curent.
struct ProfileView: View {
    
    // ViewModel asociat view-ului. Gestionează logica de afișare a datelor profilului.
    @StateObject private var viewModel = ProfileViewModel()
    @Binding var showSignInview: Bool
    
    @State private var isImagePickerPresented = false
    @State private var selectedImage: UIImage?
    
    var body: some View {
        List {
            
            
            // Verifică dacă există un utilizator și afișează datele sale.
            if let user = viewModel.user {
                
                
                if let photoURLString = user.photoURL, let photoURL = URL(string: photoURLString) {
                    AsyncImage(url: photoURL) { image in
                        image.resizable()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .padding()
                    .onTapGesture {
                        isImagePickerPresented = true
                    }
                }

                
                
                Text("UserID: \(user.userId)")
                
                // Afișează data creării contului dacă este disponibilă.
                if let email = user.email {
                    Text("E-mail: \(email)")
                }
                
    
            }
        }
        .task {
            // Încarcă datele utilizatorului curent când view-ul apare.
            try? await viewModel.loadCurrentUser()
        }
        .sheet(isPresented: $isImagePickerPresented) {
            PhotoPicker(selectedImage: $selectedImage) {
                guard let selectedImage = selectedImage else { return }
                Task {
                    try? await viewModel.uploadImageToStorage(selectedImage)
                }
            }
        }
        .navigationTitle("Profile")
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




