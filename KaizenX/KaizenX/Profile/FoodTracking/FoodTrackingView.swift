//
//  FoodTrackingView.swift
//  KaizenX
//
//  Created by Cristi Sandu on 17.01.2025.
//

import SwiftUI

struct FoodTrackingView: View {
    @StateObject private var viewModel = FoodTrackingViewModel()
    @State private var selectedDate = Date()
    @State private var showingAddFoodView = false

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: selectedDate)
    }

    var body: some View {
        NavigationView {
            VStack {
                Text("Monitorizare Alimentație")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()

                DatePicker("Selectează data", selection: $selectedDate, displayedComponents: [.date])
                    .datePickerStyle(CompactDatePickerStyle())
                    .padding()

                ScrollView {
                    VStack(spacing: 15) {
                        FoodProgressBar(title: "Calorii", current: viewModel.totalCalories, goal: 2500, unit: "kcal")
                        FoodProgressBar(title: "Proteine", current: viewModel.totalProtein, goal: 150, unit: "g")
                        FoodProgressBar(title: "Carbohidrați", current: viewModel.totalCarbs, goal: 250, unit: "g")
                        FoodProgressBar(title: "Grăsimi", current: viewModel.totalFats, goal: 70, unit: "g")
                        FoodProgressBar(title: "Grăsimi saturate", current: viewModel.totalSaturatedFats, goal: 20, unit: "g")
                        FoodProgressBar(title: "Glucide", current: viewModel.totalGlucides, goal: 60, unit: "g")
                        FoodProgressBar(title: "Fibre", current: viewModel.totalFibers, goal: 35, unit: "g")
                    }
                    .padding(.horizontal)

                    Text("Alimente consumate")
                        .font(.headline)
                        .padding(.top, 10)

                    ForEach(viewModel.foods) { food in
                        FoodEntryView(food: food)
                    }
                }

                Spacer()

                Button(action: {
                    showingAddFoodView = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .font(.title)
                        Text("Adaugă Aliment")
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.green)
                    .cornerRadius(10)
                }
                .padding()
                .sheet(isPresented: $showingAddFoodView) {
                    AddFoodView(viewModel: viewModel, selectedDate: formattedDate)
                }
            }
            .onAppear {
                Task {
                    await viewModel.fetchDailyFoodEntries(for: formattedDate)
                }
            }
            .onChange(of: selectedDate) { oldDate, newDate in
                Task {
                    await viewModel.fetchDailyFoodEntries(for: formattedDate)
                }
            }
            .navigationBarTitle("Alimentație", displayMode: .inline)
        }
    }
}
