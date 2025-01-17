//
//  AddFoodView.swift
//  KaizenX
//
//  Created by Cristi Sandu on 17.01.2025.
//

import SwiftUI

struct AddFoodView: View {
    @ObservedObject var databaseViewModel: FoodDatabaseViewModel
    @ObservedObject var trackingViewModel: FoodTrackingViewModel
    let selectedDate: String

    @State private var selectedFood: FoodItem?
    @State private var grams: String = ""
    @State private var showingNewFoodForm = false

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(databaseViewModel.savedFoods) { food in
                        Button(action: { selectedFood = food }) {
                            HStack {
                                Text(food.name)
                                Spacer()
                                if selectedFood?.id == food.id {
                                    Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                                }
                            }
                        }
                    }
                }

                TextField("Grame consumate", text: $grams)
                    .keyboardType(.numberPad)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button("Adaugă în jurnal") {
                    if let food = selectedFood, let gramsInt = Int(grams) {
                        let ratio = Double(gramsInt) / 100.0
                        let newFoodEntry = FoodEntry(
                            name: food.name,
                            calories: Int(Double(food.caloriesPer100g) * ratio),
                            protein: Int(Double(food.proteinPer100g) * ratio),
                            carbs: Int(Double(food.carbsPer100g) * ratio),
                            fats: Int(Double(food.fatsPer100g) * ratio),
                            saturatedFats: Int(Double(food.saturatedFatsPer100g) * ratio),
                            glucides: Int(Double(food.glucidesPer100g) * ratio),
                            fibers: Int(Double(food.fibersPer100g) * ratio)
                        )

                        Task {
                            await trackingViewModel.addFoodEntry(newFoodEntry, for: selectedDate)
                        }
                    }
                }
                .disabled(selectedFood == nil || grams.isEmpty)

                Button("Adaugă produs nou") {
                    showingNewFoodForm = true
                }
                .padding()

                Spacer()
            }
            .navigationTitle("Selectează sau Adaugă")
            .onAppear {
                Task {
                    await databaseViewModel.fetchSavedFoods()
                }
            }
            .sheet(isPresented: $showingNewFoodForm) {
                AddNewFoodView(databaseViewModel: databaseViewModel)
            }
        }
    }
}
