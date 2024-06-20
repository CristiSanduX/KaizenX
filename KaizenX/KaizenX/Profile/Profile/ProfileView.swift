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
    
    // Stare pentru a gestiona apăsarea butonului
    @State private var isPressed = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center) {
                if let user = viewModel.user {
                    ProfileHeaderView(user: user, isImagePickerPresented: $isImagePickerPresented, selectedImage: $selectedImage, isPressed: $isPressed)
                    
                    StatCardView(title: "Progres Pași", progress: viewModel.steps / 10000, currentValue: Int(viewModel.steps), goalValue: 10000, unit: "Pași")
                    
                    StatCardView(title: "Progres Hidratare", progress: viewModel.waterIntake / viewModel.waterIntakeGoal, currentValue: Int(viewModel.waterIntake), goalValue: Int(viewModel.waterIntakeGoal), unit: "ml")
                    
                    GymLocatorView()
                }
            }
        }
        .onAppear {
            Task {
                try? await viewModel.loadCurrentUser()
                viewModel.loadSteps()
                try? await viewModel.loadTodayWaterIntake()
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
                    SettingsView(showSignInView: $showSignInview)
                } label: {
                    Image(systemName: "gear")
                        .font(.headline)
                }
            }
        }
    }
}

struct ProfileHeaderView: View {
    let user: DBUser
    @Binding var isImagePickerPresented: Bool
    @Binding var selectedImage: UIImage?
    @Binding var isPressed: Bool
    
    var body: some View {
        VStack {
            Text("PROFIL")
                .font(.custom("Rubik-VariableFont_wght", size: 35))
                .foregroundColor(.accentColor)
                .padding(.top, 20)
                .padding(.bottom, 15)
            ZStack {
                Circle()
                    .stroke(style: .init(lineWidth: 8, lineCap: .round, lineJoin: .round))
                    .foregroundColor(.accentColor)
                    .frame(width: 220, height: 220)
                    .overlay(
                        CSXShape()
                            .stroke(style: .init(lineWidth: 2, lineCap: .round, lineJoin: .round))
                            .foregroundColor(.accentColor)
                            .frame(width: 100, height: 100)
                    )
                ZStack(alignment: .bottomTrailing) {
                    if let photoURLString = user.photoURL, let photoURL = URL(string: photoURLString) {
                        AsyncImage(url: photoURL) { image in
                            image.resizable()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 150, height: 150)
                        .clipShape(Circle())
                    } else {
                        // Adaugă o imagine placeholder dacă nu există o imagine de profil.
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 150, height: 150)
                            .clipShape(Circle())
                            .padding()
                    }
                    
                    // Butonul de editare cu semnul „plus”.
                    Button(action: {
                        isPressed = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            isPressed = false
                            isImagePickerPresented = true
                        }
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 25))
                            .foregroundColor(isPressed ? .gray : .white)
                            .background(isPressed ? Color.gray : Color.accentColor)
                            .scaleEffect(isPressed ? 1.5 : 1.0)
                            .clipShape(Circle())
                    }
                    .padding(10)
                    .animation(.easeInOut(duration: 0.3), value: isPressed)
                }
            }
            .padding(.top, 30)
            .padding(.bottom, 30)
        }
    }
}

struct StatCardView: View {
    let title: String
    let progress: Double
    let currentValue: Int
    let goalValue: Int
    let unit: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundColor(.accentColor)
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
            HStack {
                Text("\(currentValue) \(unit)")
                Spacer()
                Text("Obiectiv: \(goalValue) \(unit)")
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 20).fill(Color(.systemGray6)))
        .shadow(radius: 5)
        .padding(.horizontal)
    }
}

struct GymLocatorView: View {
    @StateObject private var locationManager = LocationManager()

    var body: some View {
        VStack {
            Text("Săli de sport din apropiere")
                .font(.title2)
                .foregroundColor(.accentColor)
                .padding(.top, 25)
                .padding(.bottom, 20)
            GoogleMapsView(locationManager: locationManager)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(radius: 10)
                .frame(height: 400)
                .padding(.horizontal)
                .padding(.bottom, 10)
        }
    }
}


