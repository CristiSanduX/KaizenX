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
                    if let food = selectedFood, let gramsDouble = Double(grams) {
                        let ratio = gramsDouble / 100.0
                        let newFoodEntry = FoodEntry(
                            name: food.name,
                            grams: gramsDouble,
                            calories: (food.caloriesPer100g * ratio).rounded(toPlaces: 1),
                            protein: (food.proteinPer100g * ratio).rounded(toPlaces: 1),
                            carbs: (food.carbsPer100g * ratio).rounded(toPlaces: 1),
                            fats: (food.fatsPer100g * ratio).rounded(toPlaces: 1),
                            saturatedFats: (food.saturatedFatsPer100g * ratio).rounded(toPlaces: 1),
                            glucides: (food.glucidesPer100g * ratio).rounded(toPlaces: 1),
                            fibers: (food.fibersPer100g * ratio).rounded(toPlaces: 1)
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
