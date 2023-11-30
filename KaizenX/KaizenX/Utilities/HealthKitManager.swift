//
//  HealthKitManager.swift
//  KaizenX
//
//  Created by Cristi Sandu on 30.11.2023.
//

import Foundation
import HealthKit

/// Managerul HealthKit este responsabil pentru toate interacțiunile cu HealthKit.
class HealthKitManager {
    /// O instanță singleton a managerului HealthKit.
    static let shared = HealthKitManager()
    
    /// Referința la HealthStore pentru interogări și cereri de date.
    private var healthStore: HKHealthStore?
    
    /// Inițializează `HealthKitManager` și setează `healthStore` dacă datele de sănătate sunt disponibile.
    init() {
        if HKHealthStore.isHealthDataAvailable() {
            healthStore = HKHealthStore()
        }
    }
    
    /// Solicită autorizația utilizatorului pentru a accesa datele de sănătate.
    /// - Parameter completion: Un bloc de completare care returnează un bool indicând succesul autorizației.
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        
        // Solicită permisiunea de a citi numărul de pași.
        healthStore?.requestAuthorization(toShare: [], read: [stepType]) { success, error in
            completion(success)
        }
    }
    
    /// Extrage numărul total de pași pentru utilizator pentru ziua curentă.
    /// - Parameter completion: Un bloc de completare care returnează numărul de pași ca un double.
    func fetchSteps(completion: @escaping (Double) -> Void) {
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        
        // Creează o perioadă de timp de la începutul zilei curente până acum.
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        // Creează și execută o interogare pentru a obține suma pașilor.
        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, statistics, _ in
            let stepCount = statistics?.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0
            completion(stepCount)
        }
        
        healthStore?.execute(query)
    }
}
