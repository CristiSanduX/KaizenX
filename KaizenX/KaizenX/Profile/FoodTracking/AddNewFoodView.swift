//
//  AddNewFoodView.swift
//  KaizenX
//
//  Created by Cristi Sandu on 17.01.2025.
//

import SwiftUI

struct AddNewFoodView: View {
    @ObservedObject var databaseViewModel: FoodDatabaseViewModel

    @State private var name: String = ""
    @State private var calories: String = ""
    @State private var protein: String = ""
    @State private var carbs: String = ""
    @State private var fats: String = ""
    @State private var saturatedFats: String = ""
    @State private var glucides: String = ""
    @State private var fibers: String = ""

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Detalii produs")) {
                    TextField("Nume produs", text: $name)

                    TextField("Calorii per 100g", text: $calories)
                        .keyboardType(.numberPad)

                    TextField("Proteine per 100g", text: $protein)
                        .keyboardType(.numberPad)

                    TextField("Carbohidrați per 100g", text: $carbs)
                        .keyboardType(.numberPad)

                    TextField("Grăsimi per 100g", text: $fats)
                        .keyboardType(.numberPad)

                    TextField("Grăsimi saturate per 100g", text: $saturatedFats)
                        .keyboardType(.numberPad)

                    TextField("Glucide per 100g", text: $glucides)
                        .keyboardType(.numberPad)

                    TextField("Fibre per 100g", text: $fibers)
                        .keyboardType(.numberPad)
                }

                Button("Salvează produs") {
                    if let caloriesInt = Int(calories),
                       let proteinInt = Int(protein),
                       let carbsInt = Int(carbs),
                       let fatsInt = Int(fats),
                       let saturatedFatsInt = Int(saturatedFats),
                       let glucidesInt = Int(glucides),
                       let fibersInt = Int(fibers) {

                        let newFood = FoodItem(
                            name: name,
                            caloriesPer100g: caloriesInt,
                            proteinPer100g: proteinInt,
                            carbsPer100g: carbsInt,
                            fatsPer100g: fatsInt,
                            saturatedFatsPer100g: saturatedFatsInt,
                            glucidesPer100g: glucidesInt,
                            fibersPer100g: fibersInt
                        )

                        Task {
                            await databaseViewModel.addNewFood(newFood)
                        }

                        presentationMode.wrappedValue.dismiss()
                    }
                }
                .disabled(name.isEmpty || calories.isEmpty || protein.isEmpty || carbs.isEmpty || fats.isEmpty || saturatedFats.isEmpty || glucides.isEmpty || fibers.isEmpty)
                .padding()
            }
            .navigationTitle("Adaugă produs nou")
        }
    }
}
