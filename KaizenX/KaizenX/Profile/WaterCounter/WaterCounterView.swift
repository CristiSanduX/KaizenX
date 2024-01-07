//
//  WaterCounterView.swift
//  KaizenX
//
//  Created by Cristi Sandu on 23.12.2023.
//

import SwiftUI

struct WaterCounterView: View {
    @StateObject private var viewModel = WaterCounterViewModel()
    
    @State private var isWaterIntakeSheetPresented = false // Starea pentru afișarea modalului de introducere a apei
    @State private var manualWaterIntake: String = "" // Valoarea introdusă manual pentru cantitatea de apă

    // Funcția care gestionează adăugarea apei
    var addWater: () -> Void {
        return {
            Task {
                let amountToAdd = Double(Int(manualWaterIntake) ?? 0)
                await viewModel.addWaterIntake(amount: amountToAdd)
                try? await viewModel.saveDailyWaterIntake(amount: amountToAdd)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                // Secțiunea principală a UI-ului care afișează cantitatea de apă consumată
                Section(header: Text("Cantitatea de apă consumată")) {
                    VStack {
                        // Vizualizarea animației cu apa
                        WaterAnimationView(waterIntakeGoal: viewModel.waterIntakeGoal, waterIntake: $viewModel.waterIntake)

                        Spacer() // Spațiu suplimentar pentru estetică

                        // Linia cu informații despre consumul de apă și butonul pentru adăugare
                        HStack {
                            Text("Consumat: \(Int(viewModel.waterIntake)) ml din 2000 ml")
                            Spacer()

                            // Butonul pentru adăugarea apei
                            Button(action: {
                                isWaterIntakeSheetPresented = true
                            }) {
                                Image(systemName: "plus.circle")
                                    .foregroundColor(.blue)
                            }
                            .sheet(isPresented: $isWaterIntakeSheetPresented) {
                                WaterIntakeInputView(isPresented: $isWaterIntakeSheetPresented, manualWaterIntake: $manualWaterIntake) {
                                    addWater()
                                }
                            }
                        }
                        .padding(.top)
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
                .onAppear {
                    Task {
                        // Încarcă datele necesare la apariția view-ului
                        try? await viewModel.loadCurrentUser()
                        try? await viewModel.loadTodayWaterIntake()
                        try? await viewModel.checkAndResetWaterIntake()
                    }
                }
            }
        }
    }
}

struct ProgressBar: View {
    @Binding var value: Double
    var maxValue: Double

    var body: some View {
        // Bara de progres care vizualizează cantitatea de apă consumată
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle().frame(width: geometry.size.width, height: geometry.size.height)
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
        // View-ul pentru introducerea manuală a cantității de apă
        NavigationView {
            Form {
                TextField("Introdu cantitatea de apă în ml", text: $manualWaterIntake)
                    .keyboardType(.numberPad)
                
                Button("Adaugă") {
                    addWater()
                    isPresented = false
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
    WaterCounterView()
}
