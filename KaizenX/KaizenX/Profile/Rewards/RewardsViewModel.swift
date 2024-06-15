//
//  RewardsViewModel.swift
//  KaizenX
//
//  Created by Cristi Sandu on 15.06.2024.
//

import Foundation
import SwiftUI
import HealthKit

struct Achievement: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let description: String
    let criteria: Criteria
    var isEarned: Bool = false
    var achievedDate: Date? = nil
    var difficulty: Difficulty
    
    enum Criteria {
        case dailySteps(Int)
        case weeklySteps(Int)
        case monthlySteps(Int)
        case consecutiveWeeklySteps(Int, Int) // Numar de zile consecutive, numar total de pasi
    }
    
    enum Difficulty {
        case easy, medium, hard
        
        var color: Color {
            switch self {
            case .easy:
                return .green
            case .medium:
                return .orange
            case .hard:
                return .red
            }
        }
    }

    static func == (lhs: Achievement, rhs: Achievement) -> Bool {
        return lhs.id == rhs.id
    }
}

let allAchievements: [Achievement] = [
    Achievement(title: "10.000 de pași într-o zi", description: "Realizează 10.000 de pași într-o singură zi", criteria: .dailySteps(10000), difficulty: .easy),
    Achievement(title: "20.000 de pași într-o zi", description: "Realizează 20.000 de pași într-o singură zi", criteria: .dailySteps(20000), difficulty: .medium),
    Achievement(title: "30.000 de pași într-o zi", description: "Realizează 30.000 de pași într-o singură zi", criteria: .dailySteps(30000), difficulty: .hard),
    Achievement(title: "150.000 de pași într-o lună", description: "Realizează 150.000 de pași într-o lună", criteria: .monthlySteps(150000), difficulty: .medium),
    Achievement(title: "300.000 de pași într-o lună", description: "Realizează 300.000 de pași într-o lună", criteria: .monthlySteps(300000), difficulty: .hard),
    Achievement(title: "50.000 de pași în 7 zile consecutive", description: "Realizează 50.000 de pași în 7 zile consecutive", criteria: .consecutiveWeeklySteps(7, 50000), difficulty: .medium),
]

@MainActor
class RewardsViewModel: ObservableObject {
    @Published var achievements: [Achievement] = allAchievements
    private let healthKitManager = HealthKitManager.shared
    
    func checkAchievements() {
        healthKitManager.requestAuthorization { [weak self] success in
            guard success else { return }
            self?.fetchStepDataForAchievements()
        }
    }
    
    private func fetchStepDataForAchievements() {
        let startDate = Calendar.current.date(byAdding: .year, value: -1, to: Date())!
        let endDate = Date()
        
        healthKitManager.fetchSteps(startDate: startDate, endDate: endDate) { [weak self] result in
            switch result {
            case .success(let stepsData):
                self?.evaluateAchievements(stepsData: stepsData)
            case .failure(let error):
                print("Error fetching steps: \(error)")
            }
        }
    }
    
    private func evaluateAchievements(stepsData: [Date: Double]) {
        let sortedStepsData = stepsData.sorted(by: { $0.key < $1.key })
        
        for index in achievements.indices {
            var achievement = achievements[index]
            
            switch achievement.criteria {
            case .dailySteps(let requiredSteps):
                achievement = checkDailySteps(achievement, requiredSteps: requiredSteps, stepsData: sortedStepsData)
            case .weeklySteps(let requiredSteps):
                achievement = checkWeeklySteps(achievement, requiredSteps: requiredSteps, stepsData: sortedStepsData)
            case .monthlySteps(let requiredSteps):
                achievement = checkMonthlySteps(achievement, requiredSteps: requiredSteps, stepsData: sortedStepsData)
            case .consecutiveWeeklySteps(let days, let requiredSteps):
                achievement = checkConsecutiveSteps(achievement, for: days, with: requiredSteps, in: sortedStepsData)
            }
            
            achievements[index] = achievement
        }
    }
    
    private func checkDailySteps(_ achievement: Achievement, requiredSteps: Int, stepsData: [(key: Date, value: Double)]) -> Achievement {
        var updatedAchievement = achievement
        for (date, steps) in stepsData {
            if steps >= Double(requiredSteps) {
                updatedAchievement.isEarned = true
                updatedAchievement.achievedDate = date
            }
        }
        return updatedAchievement
    }
    
    private func checkWeeklySteps(_ achievement: Achievement, requiredSteps: Int, stepsData: [(key: Date, value: Double)]) -> Achievement {
        // Check for weekly steps achievement logic here
        return achievement
    }
    
    private func checkMonthlySteps(_ achievement: Achievement, requiredSteps: Int, stepsData: [(key: Date, value: Double)]) -> Achievement {
        var updatedAchievement = achievement
        let calendar = Calendar.current
        
        let groupedByMonth = Dictionary(grouping: stepsData) { (date, _) -> String in
            let components = calendar.dateComponents([.year, .month], from: date)
            return "\(components.year!)-\(components.month!)"
        }
        
        for (_, monthlyData) in groupedByMonth {
            let totalSteps = monthlyData.reduce(0) { $0 + $1.value }
            if totalSteps >= Double(requiredSteps) {
                updatedAchievement.isEarned = true
                updatedAchievement.achievedDate = monthlyData.last?.key
            }
        }
        
        return updatedAchievement
    }
    
    private func checkConsecutiveSteps(_ achievement: Achievement, for days: Int, with requiredSteps: Int, in stepsData: [(key: Date, value: Double)]) -> Achievement {
        var updatedAchievement = achievement
        for i in 0...(stepsData.count - days) {
            let segment = stepsData[i..<(i + days)]
            let totalSteps = segment.reduce(0) { $0 + $1.value }
            if totalSteps >= Double(requiredSteps) {
                updatedAchievement.isEarned = true
                updatedAchievement.achievedDate = segment.last?.key
            }
        }
        return updatedAchievement
    }
    
    func getAchievementDate(for achievement: Achievement) -> String {
        guard let date = achievement.achievedDate else { return "" }
        
        let formatter = DateFormatter()
        let calendar = Calendar.current
        let adjustedDate: Date
        
        switch achievement.criteria {
        case .monthlySteps(_):
            adjustedDate = date
            formatter.dateFormat = "MMMM yyyy"
        default:
            adjustedDate = calendar.date(byAdding: .day, value: 1, to: date)!
            formatter.dateFormat = "dd MMM yyyy"
        }
        
        return formatter.string(from: adjustedDate)
    }
    
    

}
