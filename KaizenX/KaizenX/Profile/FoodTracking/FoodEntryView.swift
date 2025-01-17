//
//  FoodEntryView.swift
//  KaizenX
//
//  Created by Cristi Sandu on 17.01.2025.
//

import SwiftUI

struct FoodEntryView: View {
    let food: FoodEntry

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(food.name)
                    .font(.headline)
                    .fontWeight(.bold)

                Text("Calorii: \(food.calories) kcal")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                Text("Proteine: \(food.protein)g | Carbo: \(food.carbs)g | Grăsimi: \(food.fats)g")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .shadow(radius: 3)
        .padding(.horizontal)
    }
}

