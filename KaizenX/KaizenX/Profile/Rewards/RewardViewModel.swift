//
//  RewardViewModel.swift
//  KaizenX
//
//  Created by Cristi Sandu on 13.06.2024.
//

import Foundation

@MainActor
class RewardViewModel: ObservableObject {
    @Published var stepRewards: [String] = []
    @Published var hydrationRewards: [String] = []

    private let healthKitManager = HealthKitManager.shared
    
    func checkRewards() async {
        healthKitManager.requestAuthorization { [weak self] success in
            guard success else { return }
            self?.fetchStepDataForRewards()
            // Adaugă aici logica pentru hidratare
        }
    }
    
    private func fetchStepDataForRewards() {
        healthKitManager.fetchStepsForLastDays(30) { [weak self] result in
            switch result {
            case .success(let stepsData):
                let streak = self?.calculateStepStreak(data: stepsData) ?? 0
                if streak >= 10 {
                    self?.stepRewards.append("Premiu 1: 10 zile la rând cu 10.000 pași")
                }
                if streak >= 20 {
                    self?.stepRewards.append("Premiu 2: 20 zile la rând cu 10.000 pași")
                }
            case .failure(let error):
                print("Error fetching steps data: \(error)")
            }
        }
    }
    
    private func calculateStepStreak(data: [Double]) -> Int {
        var streak = 0
        var maxStreak = 0
        
        for steps in data {
            if steps >= 10000 {
                streak += 1
                maxStreak = max(maxStreak, streak)
            } else {
                streak = 0
            }
        }
        
        return maxStreak
    }
}

