//
//  WaterCounterViewModel.swift
//  KaizenX
//
//  Created by Cristi Sandu on 23.12.2023.
//

import SwiftUI
import FirebaseFirestore

struct WaterEntry: Identifiable {
    let id: String
    let amount: Double
    let timestamp: Date
}

@MainActor
final class WaterCounterViewModel: ObservableObject {

    @Published private(set) var user: DBUser? = nil
    @Published var waterIntake: Double = 0
    @Published private(set) var waterEntries: [WaterEntry] = []
    @Published var waterGoal: Double {
        didSet { UserDefaults.standard.set(waterGoal, forKey: "waterGoal") }
    }

    static let goalOptions: [Double] = stride(from: 1000, through: 4000, by: 250).map { Double($0) }

    init() {
        let saved = UserDefaults.standard.double(forKey: "waterGoal")
        waterGoal = saved > 0 ? saved : 2500
    }

    private static let dateKeyFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy_MM_dd"
        return f
    }()

    private var todayKey: String {
        Self.dateKeyFormatter.string(from: Date())
    }

    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }

    func addWaterIntake(amount: Double) async throws {
        guard let userId = user?.userId else { return }

        let db = Firestore.firestore()
        let dailyRef = db.collection("users").document(userId)
            .collection("daily_intakes").document(todayKey)

        let entryRef = dailyRef.collection("entries").document()
        let entryData: [String: Any] = ["amount": amount, "timestamp": Date()]
        try await entryRef.setData(entryData)

        let document = try await dailyRef.getDocument()
        let current = (document.data()?["intake"] as? Double) ?? 0
        try await dailyRef.setData(["date": Date(), "intake": current + amount], merge: true)

        let newEntry = WaterEntry(id: entryRef.documentID, amount: amount, timestamp: Date())
        waterEntries.append(newEntry)
        waterIntake = current + amount
    }

    func deleteWaterEntry(_ entry: WaterEntry) async throws {
        guard let userId = user?.userId else { return }

        let db = Firestore.firestore()
        let dailyRef = db.collection("users").document(userId)
            .collection("daily_intakes").document(todayKey)

        try await dailyRef.collection("entries").document(entry.id).delete()

        waterEntries.removeAll { $0.id == entry.id }
        let newTotal = waterEntries.reduce(0) { $0 + $1.amount }
        waterIntake = newTotal

        try await dailyRef.setData(["intake": newTotal], merge: true)
    }

    func loadTodayWaterIntake() async throws {
        guard let userId = user?.userId else { return }

        let db = Firestore.firestore()
        let dailyRef = db.collection("users").document(userId)
            .collection("daily_intakes").document(todayKey)

        let snapshot = try await dailyRef.collection("entries")
            .order(by: "timestamp", descending: false)
            .getDocuments()

        let entries: [WaterEntry] = snapshot.documents.compactMap { doc in
            guard let amount = doc.data()["amount"] as? Double,
                  let ts = doc.data()["timestamp"] as? Timestamp else { return nil }
            return WaterEntry(id: doc.documentID, amount: amount, timestamp: ts.dateValue())
        }

        waterEntries = entries
        waterIntake = entries.reduce(0) { $0 + $1.amount }
    }
}
