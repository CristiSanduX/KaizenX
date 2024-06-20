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
    
    enum HealthKitError: Error {
        case dataUnavailable
        case authorizationFailed
    }
    
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
    
    func requestAuthorization2(completion: @escaping (Bool) -> Void) {
            let workoutType = HKObjectType.workoutType()
            let typesToRead: Set<HKObjectType> = [workoutType]
            
            healthStore?.requestAuthorization(toShare: nil, read: typesToRead) { (success, error) in
                completion(success)
            }
        }
    func fetchWorkouts(completion: @escaping ([HKWorkout]) -> Void) {
            let workoutType = HKObjectType.workoutType()
            let query = HKSampleQuery(sampleType: workoutType, predicate: nil, limit: 0, sortDescriptors: nil) { (query, samples, error) in
                if let workouts = samples as? [HKWorkout] {
                    completion(workouts)
                } else {
                    completion([])
                }
            }
            
            healthStore?.execute(query)
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
    
    /// Extrage numărul de pași pentru utilizator pentru ultimele `days` zile.
    /// - Parameters:
    ///   - days: Numărul de zile pentru care să obțină date.
    ///   - completion: Un bloc de completare care returnează o listă de numere de pași pentru fiecare zi.
    func fetchStepsForLastDays(_ days: Int, completion: @escaping (Result<[Double], Error>) -> Void) {
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let now = Date()
        let startDate = Calendar.current.date(byAdding: .day, value: -days, to: now)!
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: now, options: .strictStartDate)
        
        var stepsData: [Double] = Array(repeating: 0.0, count: days)
        let query = HKSampleQuery(sampleType: stepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { query, samples, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            samples?.forEach { sample in
                if let quantitySample = sample as? HKQuantitySample {
                    let stepCount = quantitySample.quantity.doubleValue(for: .count())
                    let sampleDate = quantitySample.startDate
                    let dayIndex = Calendar.current.dateComponents([.day], from: startDate, to: sampleDate).day!
                    stepsData[dayIndex] += stepCount
                }
            }
            completion(.success(stepsData))
        }
        healthStore?.execute(query)
    }
    
    /// Extrage numărul total de pași pentru o perioadă dată.
    /// - Parameters:
    ///   - startDate: Data de început.
    ///   - endDate: Data de sfârșit.
    ///   - completion: Un bloc de completare care returnează un dicționar cu date și numărul de pași sau o eroare.
    func fetchSteps(startDate: Date, endDate: Date, completion: @escaping (Result<[Date: Double], Error>) -> Void) {
            guard let healthStore = healthStore else {
                completion(.failure(HealthKitError.dataUnavailable))
                return
            }
            
            let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
            let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
            
            var interval = DateComponents()
            interval.day = 1
            
            let query = HKStatisticsCollectionQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum, anchorDate: startDate, intervalComponents: interval)
            
            query.initialResultsHandler = { query, results, error in
                guard let statsCollection = results else {
                    completion(.failure(error ?? HealthKitError.dataUnavailable))
                    return
                }
                
                var stepsData: [Date: Double] = [:]
                statsCollection.enumerateStatistics(from: startDate, to: endDate) { statistics, stop in
                    if let quantity = statistics.sumQuantity() {
                        let steps = quantity.doubleValue(for: .count())
                        stepsData[statistics.startDate] = steps
                    }
                }
                
                DispatchQueue.main.async {
                    completion(.success(stepsData))
                }
            }
            
            healthStore.execute(query)
        }
    
}
