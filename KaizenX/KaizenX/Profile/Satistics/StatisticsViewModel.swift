//
//  StatisticsViewModel.swift
//  KaizenX
//
//  Created by Cristi Sandu on 13.06.2024.
//

import Foundation
import SwiftUI

struct DailySteps: Identifiable {
    let id = UUID()
    let day: Int
    let steps: Double
}

@MainActor
class StatisticsViewModel: ObservableObject {
    @Published var weeklyAverageSteps: String = ""
    @Published var monthlyAverageSteps: String = ""
    @Published var dailySteps: [DailySteps] = []

    private let healthKitManager = HealthKitManager.shared
    
    func calculateStatistics() async {
        healthKitManager.requestAuthorization { [weak self] success in
            guard success else { return }
            self?.fetchStepDataForStatistics()
        }
    }
    
    private func fetchStepDataForStatistics() {
        healthKitManager.fetchStepsForLastDays(30) { [weak self] result in
            switch result {
            case .success(let stepsData):
                let last7DaysData = Array(stepsData.suffix(7))
                self?.dailySteps = last7DaysData.enumerated().map { index, steps in
                    DailySteps(day: index + 1, steps: steps)
                }
                let weeklyAverage = last7DaysData.reduce(0, +) / Double(last7DaysData.count)
                let monthlyAverage = stepsData.reduce(0, +) / Double(stepsData.count)
                self?.weeklyAverageSteps = self?.formatNumber(weeklyAverage) ?? "0"
                self?.monthlyAverageSteps = self?.formatNumber(monthlyAverage) ?? "0"
            case .failure(let error):
                print("Error fetching statistics: \(error)")
            }
        }
    }
    
    private func formatNumber(_ number: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ""
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: number)) ?? "0"
    }
    
    func colorForSteps(_ steps: Double) -> Color {
        switch steps {
        case ..<5000:
            return .red
        case 5000..<7000:
            return .yellow
        case 7000..<10000:
            return .blue
        case 10000...:
            return .green
        default:
            return .primary
        }
    }
    
    func emoticonForSteps(_ steps: Double) -> String {
        switch steps {
        case ..<5000:
            return "😔"
        case 5000..<7000:
            return "⏳"
        case 7000..<10000:
            return "👌🏻"
        case 10000...:
            return "💪🏻🔥"
        default:
            return ""
        }
    }
}


