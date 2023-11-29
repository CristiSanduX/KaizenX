//
//  HealthKitManager.swift
//  KaizenX
//
//  Created by Cristi Sandu on 30.11.2023.
//

import Foundation
import HealthKit


class HealthKitManager {
    static let shared = HealthKitManager()
    private var healthStore: HKHealthStore?

    init() {
        if HKHealthStore.isHealthDataAvailable() {
            healthStore = HKHealthStore()
        }
    }

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        healthStore?.requestAuthorization(toShare: [], read: [stepType]) { success, error in
            completion(success)
        }
    }

    func fetchSteps(completion: @escaping (Double) -> Void) {
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)

        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, statistics, _ in
            let stepCount = statistics?.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0
            completion(stepCount)
        }

        healthStore?.execute(query)
    }
}
