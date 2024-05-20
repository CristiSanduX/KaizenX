import SwiftUI

struct WaterCounterView: View {
    @StateObject private var viewModel = WaterCounterViewModel()
    
    @State private var isWaterIntakeSheetPresented = false // Starea pentru afișarea modalului de introducere a apei
    @State private var manualWaterIntake: String = "" // Valoarea introdusă manual pentru cantitatea de apă
    
    // Funcția care gestionează adăugarea apei
    var addWater: () -> Void {
        return {
            Task {
                try? await viewModel.loadTodayWaterIntake()
                let amountToAdd = Double(Int(manualWaterIntake) ?? 0)
                await viewModel.addWaterIntake(amount: amountToAdd)
                try? await viewModel.saveDailyWaterIntake(amount: amountToAdd)
            }
        }
    }
    
    var body: some View {
        VStack {
            Text("CONSUMUL TĂU DE APĂ")
                .font(.custom("Rubik-VariableFont_wght", size: 25))
                .foregroundColor(.accentColor)
                .padding(.top, 20)
                .padding(.bottom, 10)
            
            WaterAnimationView(waterIntakeGoal: viewModel.waterIntakeGoal, waterIntake: $viewModel.waterIntake)
                .frame(height: 350)
                .padding(.top, 10)
            
            Spacer()
            
            VStack {
                HStack {
                    Text("Consumat: \(Int(viewModel.waterIntake)) ml")
                        .font(.headline)
                    Spacer()
                    Button(action: {
                        isWaterIntakeSheetPresented = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .font(.headline)
                            Text("Adaugă Apă")
                                .font(.headline)
                                .fontWeight(.bold)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .foregroundColor(.white)
                        .background(Color.accentColor)
                        .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 10)
                
                ProgressBar(value: $viewModel.waterIntake, maxValue: viewModel.waterIntakeGoal)
                    .frame(height: 20)
                    .padding(.horizontal)
                
                Text("Scopul zilnic este să consumi cel puțin 2 litri de apă.")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .padding(.top, 10)
                
                if viewModel.waterIntake >= viewModel.waterIntakeGoal {
                    Text("Felicitări! Ai atins obiectivul de hidratare pentru azi.")
                        .foregroundColor(.green)
                } else {
                    Text("Continuă să te hidratezi pentru a atinge obiectivul zilnic.")
                        .foregroundColor(.orange)
                }
            }
            
            Spacer()
        }
        .background(Color(.systemGray6).edgesIgnoringSafeArea(.all))
        .sheet(isPresented: $isWaterIntakeSheetPresented) {
            WaterIntakeInputView(isPresented: $isWaterIntakeSheetPresented, manualWaterIntake: $manualWaterIntake) {
                addWater()
            }
        }
        .onAppear {
            Task {
                // Încarcă datele necesare la apariția view-ului
                try? await viewModel.loadCurrentUser()
                try? await viewModel.loadTodayWaterIntake()
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
                Section(header: Text("Introduceți cantitatea de apă (ml)").font(.headline)) {
                    TextField("Introdu cantitatea de apă în ml", text: $manualWaterIntake)
                        .keyboardType(.numberPad)
                }
                
                Button(action: {
                    addWater()
                    isPresented = false
                }) {
                    HStack {
                        Spacer()
                        Text("Adaugă")
                            .font(.headline)
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.vertical, 8) 
                    .padding(.horizontal, 16)
                    .foregroundColor(.white)
                    .background(Color.accentColor)
                    .cornerRadius(8)
                }
                .padding(.top, 10)
            }
            .navigationBarTitle("Adaugă Apă", displayMode: .inline)
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
