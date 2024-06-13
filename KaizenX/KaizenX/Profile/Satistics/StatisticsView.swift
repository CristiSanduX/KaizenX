//
//  StatisticsView.swift
//  KaizenX
//
//  Created by Cristi Sandu on 13.06.2024.
//

import SwiftUI
import Charts

struct StatisticsView: View {
    @StateObject private var viewModel = StatisticsViewModel()
    @State private var showingShareSheet = false
    @State private var exportURL: URL?

    var body: some View {
        ZStack {
            VStack {
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Media pașilor în ultima săptămână:")
                        .font(.headline)
                    HStack {
                        Text(viewModel.weeklyAverageSteps)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(viewModel.colorForSteps(Double(viewModel.weeklyAverageSteps) ?? 0))
                        Text(viewModel.emoticonForSteps(Double(viewModel.weeklyAverageSteps) ?? 0))
                            .font(.title)
                    }
                    
                    Text("Media pașilor în ultima lună:")
                        .font(.headline)
                    HStack {
                        Text(viewModel.monthlyAverageSteps)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(viewModel.colorForSteps(Double(viewModel.monthlyAverageSteps) ?? 0))
                        Text(viewModel.emoticonForSteps(Double(viewModel.monthlyAverageSteps) ?? 0))
                            .font(.title)
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6)))
                .padding(.horizontal)
                
                Spacer()
                
                Picker("Perioada de timp", selection: $viewModel.selectedPeriod) {
                    ForEach(TimePeriod.allCases) { period in
                        Text(period.rawValue).tag(period)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                .onChange(of: viewModel.selectedPeriod) { _ in
                    Task {
                        await viewModel.calculateStatistics()
                    }
                }
                
                Text("Graficul pașilor zilnici (\(viewModel.selectedPeriod.rawValue))")
                    .font(.headline)
                    .padding(.bottom, 10)
                
                if !viewModel.dailySteps.isEmpty {
                    Chart(viewModel.dailySteps) { stepData in
                        LineMark(
                            x: .value("Ziua", stepData.day),
                            y: .value("Pași", stepData.steps)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(Color.darkRed)
                        .annotation(position: .top) {
                            Text("\(Int(stepData.steps))")
                                .font(.caption)
                                .foregroundColor(.primary)
                                .padding(5)
                                .background(Color(.systemBackground).opacity(0.7))
                                .cornerRadius(5)
                        }
                    }
                    .chartXAxis {
                        AxisMarks(values: xAxisValues()) { value in
                            AxisGridLine()
                            AxisValueLabel {
                                if let day = value.as(Int.self) {
                                    Text("\(day)")
                                }
                            }
                        }
                    }
                    .chartYAxis {
                        AxisMarks(position: .leading) { value in
                            AxisGridLine()
                            AxisValueLabel {
                                if let steps = value.as(Double.self) {
                                    Text("\(Int(steps))")
                                }
                            }
                        }
                    }
                    .frame(height: 300)
                    .padding(.horizontal)
                    
                    Button(action: {
                        Task {
                            exportURL = await viewModel.exportPDF()
                            showingShareSheet = true
                        }
                    }) {
                        Text("Exportă PDF")
                            .font(.body)
                                        .padding(10)
                                        .frame(width: UIScreen.main.bounds.width / 3)
                            .background(Color.darkRed)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding(.top, 20)
                    .sheet(isPresented: $showingShareSheet, content: {
                        if let exportURL = exportURL {
                            ShareSheet(activityItems: [exportURL])
                        }
                    })
                    .disabled(viewModel.isLoading)
                    .frame(maxWidth: .infinity, alignment: .center)  // Centering the button
                    .padding(.horizontal)
                    
                } else {
                    Text("Nu există date disponibile pentru perioada selectată.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding()
                }
                
                Spacer()
            }
            .disabled(viewModel.isLoading)
            
            if viewModel.isLoading {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    ProgressView("Se încarcă...")
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.darkRed))
                        .scaleEffect(1.8)
                        .foregroundColor(.white)
                }
            }
        }
        .onAppear {
            Task {
                await viewModel.calculateStatistics()
            }
        }
    }
    
    private func xAxisValues() -> [Int] {
        let count = viewModel.dailySteps.count
        guard count > 1 else { return Array(1...count) }
        
        let step: Int
        switch viewModel.selectedPeriod {
        case .last7Days:
            step = 1
        case .last30Days:
            step = 5
        case .last3Months:
            step = 10
        }
        return Array(stride(from: 1, through: count, by: step))
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        return UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    StatisticsView()
}
