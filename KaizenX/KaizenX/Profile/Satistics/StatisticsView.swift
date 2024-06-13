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
    
    var body: some View {
        VStack {
            Text("Statistici Pași")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 20)
            
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
            
            Text("Graficul pașilor zilnici (ultimele 7 zile)")
                .font(.headline)
                .padding(.bottom, 10)
            
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
                AxisMarks(values: Array(1...7)) { value in
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
            
            Spacer()
        }
        .onAppear {
            Task {
                await viewModel.calculateStatistics()
            }
        }
    }
}

#Preview {
    StatisticsView()
}
