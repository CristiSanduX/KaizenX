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
                    // Secțiune pentru afișarea detaliilor utilizatorului
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
                        
                        /*// Card pentru detalii utilizator
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Image(systemName: "envelope.fill")
                                    .foregroundColor(.accentColor)
                                Text(user.email ?? "Email necunoscut")
                                    .font(.body)
                                    .foregroundColor(.primary)
                            }
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 20).fill(Color(.systemGray6)))
                        .shadow(radius: 5)
                        .padding(.horizontal)*/
                        
                        // Progresul pașilor
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Progres Pași")
                                .font(.headline)
                                .foregroundColor(.accentColor)
                            ProgressView(value: viewModel.steps / 10000)
                                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                            HStack {
                                Text("Pași: \(Int(viewModel.steps))")
                                Spacer()
                                Text("Obiectiv: 10.000")
                            }
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 20).fill(Color(.systemGray6)))
                        .shadow(radius: 5)
                        .padding(.horizontal)
                        
                        // Progresul hidratării
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Progres Hidratare")
                                .font(.headline)
                                .foregroundColor(.accentColor)
                            ProgressView(value: viewModel.waterIntake / viewModel.waterIntakeGoal)
                                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                            HStack {
                                Text("Apă: \(Int(viewModel.waterIntake)) ml")
                                Spacer()
                                Text("Obiectiv: \(Int(viewModel.waterIntakeGoal)) ml")
                            }
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 20).fill(Color(.systemGray6)))
                        .shadow(radius: 5)
                        .padding(.horizontal)
                        
                        Spacer()
                        
                        // Săli de sport din apropiere
                        VStack {
                            Text("Săli de sport din apropiere")
                                .font(.title2)
                                .foregroundColor(.accentColor)
                                .padding(.top, 25)
                                .padding(.bottom, 20)
                            GoogleMapsView()
                                .clipShape(Circle())
                                .frame(width: 280, height: 280) // Ajustează acest frame la dimensiunea necesară
                                .padding(.horizontal)
                                .padding(.bottom, 10)
                        }
                        
                        Spacer()
                    }
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
        let length: CGFloat = min(rect.width, rect.height)
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let min = CGPoint(x: rect.minX, y: rect.minY)
        let max = CGPoint(x: rect.maxX, y: rect.maxY)
        
        var path = Path()
        
        // Linie sus
        path.move(to: CGPoint(x: center.x, y: min.y - length * 0.85))
        path.addLine(to: CGPoint(x: center.x, y: min.y - length * 0.70))
        
        // Linie jos
        path.move(to: CGPoint(x: center.x, y: max.y + length * 0.85))
        path.addLine(to: CGPoint(x: center.x, y: max.y + length * 0.70))
        
        // Linie stânga
        path.move(to: CGPoint(x: min.x - length * 0.85, y: center.y))
        path.addLine(to: CGPoint(x: min.x - length * 0.70, y: center.y))
        
        // Linie dreapta
        path.move(to: CGPoint(x: max.x + length * 0.85, y: center.y))
        path.addLine(to: CGPoint(x: max.x + length * 0.70, y: center.y))
        
        return path
            .strokedPath(.init(lineWidth: 2.5))
    }
}
