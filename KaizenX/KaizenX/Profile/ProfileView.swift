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
    
    @State private var isWaterIntakeSheetPresented = false
    @State private var manualWaterIntake: String = ""
    
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
                
                // Secțiune pentru Water Counter
                Section(header: Text("Cantitatea de apă consumată")) {
                    HStack {
                        Text("Consumat: \(viewModel.waterIntake) ml din 2000 ml")
                        Spacer()
                        
                        Button(action: {
                            isWaterIntakeSheetPresented = true
                        }) {
                            Image(systemName: "plus.circle")
                                .foregroundColor(.blue)
                        }
                        .sheet(isPresented: $isWaterIntakeSheetPresented) {
                            // Aici putem avea o nouă View sau o funcție care returnează View-ul dorit pentru sheet
                            WaterIntakeInputView(isPresented: $isWaterIntakeSheetPresented, manualWaterIntake: $manualWaterIntake) {
                                viewModel.addWaterIntake(amount: Int(manualWaterIntake) ?? 0)
                            }
                        }

                    }
                    ProgressBar(value: $viewModel.waterIntake, maxValue: viewModel.waterIntakeGoal)
                        .frame(height: 20)
                    Text("Scopul zilnic este să consumi cel puțin 2 litri de apă.")
                        .font(.footnote)
                        .foregroundColor(.gray)
                    
                    if viewModel.waterIntake >= viewModel.waterIntakeGoal {
                        Text("Felicitări! Ai atins obiectivul de hidratare pentru azi.")
                            .foregroundColor(.green)
                    } else {
                        Text("Continuă să te hidratezi pentru a atinge obiectivul zilnic.")
                            .foregroundColor(.orange)
                    }

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

struct ProgressBar: View {
    @Binding var value: Int
    var maxValue: Int

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle().frame(width: geometry.size.width , height: geometry.size.height)
                    .opacity(0.3)
                    .foregroundColor(Color(UIColor.systemTeal))

                Rectangle().frame(width: min(CGFloat(self.value) / CGFloat(self.maxValue) * geometry.size.width, geometry.size.width), height: geometry.size.height)
                    .foregroundColor(Color(UIColor.systemBlue))
                    .animation(.linear, value: value)
            }.cornerRadius(45.0)
        }
    }
}

struct WaterIntakeInputView: View {
    @Binding var isPresented: Bool
    @Binding var manualWaterIntake: String
    var addWater: () -> Void
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Introdu cantitatea de apă în ml", text: $manualWaterIntake)
                    .keyboardType(.numberPad)
                
                Button("Adaugă") {
                    addWater()
                    isPresented = false
                    manualWaterIntake = ""
                }
            }
            .navigationTitle("Adaugă apă")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Anulează") {
                        isPresented = false
                    }
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




