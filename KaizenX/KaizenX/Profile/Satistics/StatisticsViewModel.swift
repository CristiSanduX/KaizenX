//
//  StatisticsViewModel.swift
//  KaizenX
//
//  Created by Cristi Sandu on 13.06.2024.
//

import Foundation
import SwiftUI
import Charts
import PDFKit

struct DailySteps: Identifiable {
    let id = UUID()
    let day: Int
    let steps: Double
}

enum TimePeriod: String, CaseIterable, Identifiable {
    case last7Days = "Ultimele 7 zile"
    case last30Days = "Ultimele 30 de zile"
    case last3Months = "Ultimele 3 luni"
    
    var id: String { self.rawValue }
}

@MainActor
class StatisticsViewModel: ObservableObject {
    @Published var weeklyAverageSteps: String = ""
    @Published var monthlyAverageSteps: String = ""
    @Published var dailySteps: [DailySteps] = []
    @Published var selectedPeriod: TimePeriod = .last7Days
    @Published var isLoading: Bool = false

    private let healthKitManager = HealthKitManager.shared
    
    func calculateStatistics() async {
        healthKitManager.requestAuthorization { [weak self] success in
            guard success else { return }
            self?.fetchStepDataForStatistics()
        }
    }
    
    private func fetchStepDataForStatistics() {
        healthKitManager.fetchStepsForLastDays(90) { [weak self] result in
            switch result {
            case .success(let stepsData):
                let last7DaysData = Array(stepsData.suffix(7))
                let last30DaysData = Array(stepsData.suffix(30))
                let last90DaysData = stepsData
                
                self?.dailySteps = self?.getDailySteps(for: self?.selectedPeriod ?? .last7Days, stepsData: stepsData) ?? []
                
                let weeklyAverage = last7DaysData.reduce(0, +) / Double(last7DaysData.count)
                let monthlyAverage = last30DaysData.reduce(0, +) / Double(last30DaysData.count)
                
                self?.weeklyAverageSteps = self?.formatNumber(weeklyAverage) ?? "0"
                self?.monthlyAverageSteps = self?.formatNumber(monthlyAverage) ?? "0"
            case .failure(let error):
                print("Error fetching statistics: \(error)")
            }
        }
    }
    
    private func getDailySteps(for period: TimePeriod, stepsData: [Double]) -> [DailySteps] {
        let days: Int
        switch period {
        case .last7Days:
            days = 7
        case .last30Days:
            days = 30
        case .last3Months:
            days = 90
        }
        let periodStepsData = Array(stepsData.suffix(days))
        return periodStepsData.enumerated().map { index, steps in
            DailySteps(day: index + 1, steps: steps)
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

    func exportPDF() async -> URL? {
        isLoading = true
        defer { isLoading = false }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        let dateString = formatter.string(from: Date())
        
        let fileName = "Statistici Pasi (\(selectedPeriod.rawValue)) - \(dateString).pdf"
        let path = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        let pdfDocument = PDFDocument()
        let pdfPage = PDFPage(image: createImageFromView())
        pdfDocument.insert(pdfPage!, at: 0)
        
        do {
            try pdfDocument.write(to: path)
            return path
        } catch {
            print("Failed to create PDF file: \(error.localizedDescription)")
            return nil
        }
    }

    private func createImageFromView() -> UIImage {
        let view = StatisticsExportView(viewModel: self)
        let controller = UIHostingController(rootView: view)
        let viewSize = controller.view.intrinsicContentSize
        
        controller.view.frame = CGRect(origin: .zero, size: viewSize)
        
        let renderer = UIGraphicsImageRenderer(size: viewSize)
        return renderer.image { _ in
            controller.view.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
    
    func getDateInterval() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        
        let endDate = Date()
        let startDate: Date
        
        switch selectedPeriod {
        case .last7Days:
            startDate = Calendar.current.date(byAdding: .day, value: -6, to: endDate)!
        case .last30Days:
            startDate = Calendar.current.date(byAdding: .day, value: -29, to: endDate)!
        case .last3Months:
            startDate = Calendar.current.date(byAdding: .month, value: -3, to: endDate)!
        }
        
        return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
    }
}
