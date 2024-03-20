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
        VStack(alignment: .center) {
            if let user = viewModel.user {
                // Secțiune pentru afișarea detaliilor utilizatorului
                ZStack() {
                    
                    CSXShape()
                        .fill(Color.darkRed)
                        .frame(width:250, height: 200)
                        .overlay(
                            Text("Profil")
                                .font(.largeTitle)
                                .foregroundColor(.black)
                                .offset(y: -120) // Ajustează poziția titlului 
                        )
                    ZStack(alignment: .bottomTrailing) {
                        if let photoURLString = user.photoURL, let photoURL = URL(string: photoURLString) {
                            AsyncImage(url: photoURL) { image in
                                image.resizable()
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                            
                        } else {
                            // Adaugă o imagine placeholder dacă nu există o imagine de profil.
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 120, height: 120)
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
                }
                .padding(.top, 50)
                
                Spacer()
                
                
                Text("ID: \(user.userId)")
                
                if let email = user.email {
                    Text("E-mail: \(email)")
                }
                
                Text("Pași astăzi: \(viewModel.steps, specifier: "%.0f")")
                    .onAppear {
                        viewModel.loadSteps()
                    }
                
                Spacer()
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



struct CSXShape: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            
            // SUS
            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
            
            // MIJLOC DREAPTA
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
            
            // JOS
            path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
            
            // MIJLOC STÂNGA
            path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
            
        }
        
    }
}

