//
//  AddFoodView.swift
//  KaizenX
//
//  Created by Cristi Sandu on 17.01.2025.
//

import SwiftUI

struct AddFoodView: View {
    @ObservedObject var viewModel: FoodTrackingViewModel
    let selectedDate: String

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
                Section(header: Text("Detalii Aliment")) {
                    TextField("Nume aliment", text: $name)

                    TextField("Calorii (kcal)", text: $calories)
                        .keyboardType(.numberPad)

                    TextField("Proteine (g)", text: $protein)
                        .keyboardType(.numberPad)

                    TextField("Carbohidrați (g)", text: $carbs)
                        .keyboardType(.numberPad)

                    TextField("Grăsimi (g)", text: $fats)
                        .keyboardType(.numberPad)

                    TextField("Grăsimi saturate (g)", text: $saturatedFats)
                        .keyboardType(.numberPad)

                    TextField("Glucide (g)", text: $glucides)
                        .keyboardType(.numberPad)

                    TextField("Fibre (g)", text: $fibers)
                        .keyboardType(.numberPad)
                }

                Button(action: {
                    if let caloriesInt = Int(calories),
                       let proteinInt = Int(protein),
                       let carbsInt = Int(carbs),
                       let fatsInt = Int(fats),
                       let saturatedFatsInt = Int(saturatedFats),
                       let glucidesInt = Int(glucides),
                       let fibersInt = Int(fibers) {

                        let newFood = FoodEntry(
                            name: name,
                            calories: caloriesInt,
                            protein: proteinInt,
                            carbs: carbsInt,
                            fats: fatsInt,
                            saturatedFats: saturatedFatsInt,
                            glucides: glucidesInt,
                            fibers: fibersInt
                        )

                        Task {
                            await viewModel.addFoodEntry(newFood, for: selectedDate)
                        }
                        
                        presentationMode.wrappedValue.dismiss()
                    }
                }) {
                    Text("Adaugă Aliment")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.green)
                        .cornerRadius(10)
                }
                .padding()
            }
            .navigationTitle("Adaugă Aliment")
        }
    }
}
