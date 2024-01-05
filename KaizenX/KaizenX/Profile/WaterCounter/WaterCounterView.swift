//
//  WaterCounterView.swift
//  KaizenX
//
//  Created by Cristi Sandu on 23.12.2023.
//

import SwiftUI

struct WaterCounterView: View {
    @StateObject private var viewModel = WaterCounterViewModel()
    
    @State private var isWaterIntakeSheetPresented = false
    @State private var manualWaterIntake: String = ""
    
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

                // Secțiune pentru Water Counter
                Section(header: Text("Cantitatea de apă consumată")) {
                    VStack{
                        WaterAnimationView(waterIntakeGoal: viewModel.waterIntakeGoal, waterIntake: $viewModel.waterIntake)

                        Spacer()
                        Spacer()
                        
                        HStack {
                            Text("Consumat: \(Int(viewModel.waterIntake)) ml din 2000 ml")
                            Spacer()
                            
                            
                            
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

