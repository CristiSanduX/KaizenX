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
            VStack {
                Form {
                    Section(header: Text("Detalii produs")) {
                        TextField("Nume produs", text: $name)

                        TextField("Calorii per 100g", text: $calories)
                            .keyboardType(.decimalPad)

                        TextField("Proteine per 100g", text: $protein)
                            .keyboardType(.decimalPad)

                        TextField("Carbohidrați per 100g", text: $carbs)
                            .keyboardType(.decimalPad)

                        TextField("Grăsimi per 100g", text: $fats)
                            .keyboardType(.decimalPad)

                        TextField("Grăsimi saturate per 100g", text: $saturatedFats)
                            .keyboardType(.decimalPad)

                        TextField("Glucide per 100g", text: $glucides)
                            .keyboardType(.decimalPad)

                        TextField("Fibre per 100g", text: $fibers)
                            .keyboardType(.decimalPad)
                    }
                }

                Button("Salvează produs") {
                    if let caloriesDouble = Double(calories.replacingOccurrences(of: ",", with: "."))?.rounded(toPlaces: 1),
                       let proteinDouble = Double(protein.replacingOccurrences(of: ",", with: "."))?.rounded(toPlaces: 1),
                       let carbsDouble = Double(carbs.replacingOccurrences(of: ",", with: "."))?.rounded(toPlaces: 1),
                       let fatsDouble = Double(fats.replacingOccurrences(of: ",", with: "."))?.rounded(toPlaces: 1),
                       let saturatedFatsDouble = Double(saturatedFats.replacingOccurrences(of: ",", with: "."))?.rounded(toPlaces: 1),
                       let glucidesDouble = Double(glucides.replacingOccurrences(of: ",", with: "."))?.rounded(toPlaces: 1),
                       let fibersDouble = Double(fibers.replacingOccurrences(of: ",", with: "."))?.rounded(toPlaces: 1) {

                        print("✅ Produs înainte de salvare: \(name), kcal: \(caloriesDouble), proteine: \(proteinDouble)")

                        let newFood = FoodItem(
                            name: name,
                            caloriesPer100g: caloriesDouble,
                            proteinPer100g: proteinDouble,
                            carbsPer100g: carbsDouble,
                            fatsPer100g: fatsDouble,
                            saturatedFatsPer100g: saturatedFatsDouble,
                            glucidesPer100g: glucidesDouble,
                            fibersPer100g: fibersDouble
                        )

                        Task {
                            await databaseViewModel.addNewFood(newFood)
                        }

                        presentationMode.wrappedValue.dismiss()
                    } else {
                        print("❌ Conversia la Double a eșuat! Verifică inputul.")
                    }
                }


                .disabled(name.isEmpty || calories.isEmpty || protein.isEmpty || carbs.isEmpty || fats.isEmpty || saturatedFats.isEmpty || glucides.isEmpty || fibers.isEmpty)
                .padding()
            }
            .navigationTitle("Adaugă produs nou")
        }
    }
}
