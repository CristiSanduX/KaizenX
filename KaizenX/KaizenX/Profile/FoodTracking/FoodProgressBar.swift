//
//  FoodProgressBar.swift
//  KaizenX
//
//  Created by Cristi Sandu on 17.01.2025.
//

import SwiftUI

struct FoodProgressBar: View {
    let title: String
    let current: Double
    let goal: Double
    let unit: String

    var progress: Double {
        return min(current / goal, 1.0)
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text("\(title): \(String(format: "%.1f", current))/\(String(format: "%.1f", goal)) \(unit)")
                .font(.subheadline)
                .fontWeight(.bold)

            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: progress >= 1.0 ? Color.green : Color.blue))
                .frame(height: 10)
                .cornerRadius(5)
        }
        .padding(.vertical, 5)
    }
}

