//
//  StepCounterView.swift
//  KaizenX
//
//  Created by Cristi Sandu on 21.03.2024.
//

import SwiftUI

// Extensie pentru Int pentru a implementa VectorArithmetic
extension Int: VectorArithmetic {
    mutating public func scale(by rhs: Double) {
        self = Int(Double(self) * rhs)
    }
    
    public var magnitudeSquared: Double {
        Double(self * self)
    }
}

// Structura pentru a crea un modificator animat pentru un număr
struct Number: AnimatableModifier {
    var animatableData: Int
    
    init(number: Int) {
        animatableData = number
    }
    
    func body(content: Content) -> some View {
        content
            .overlay (
                Text("\(animatableData)")
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .font(.largeTitle)
            )
    }
}

// Extensie pentru View pentru a adăuga un modificator animat
extension View {
    func animationOverlay(for number: Int) -> some View {
        modifier(Number(number: number))
    }
}

// View-ul principal pentru contorizarea pașilor
struct StepCounterView: View {
    @StateObject private var viewModel = ProfileViewModel() // ViewModel pentru gestionarea datelor utilizatorului
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(style: StrokeStyle(lineWidth: 8, lineCap: .round, lineJoin: .round))
                .foregroundColor(Color(.systemGray4))
                .frame(width: 220, height: 220)
                .overlay(
                    CSXShape()
                        .stroke(style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                        .foregroundColor(.accentColor)
                        .frame(width: 100, height: 100)
                )
            
            Circle()
                .trim(from: 0, to: CGFloat(viewModel.steps/10000))
                .stroke(style: StrokeStyle(lineWidth: 8, lineCap: .round, lineJoin: .round))
                .foregroundColor(.accentColor)
                .frame(width: 220, height: 220)
                .rotationEffect(.degrees(-90))
                .shadow(radius: 5)
            
            VStack {
                Image(systemName: "shoeprints.fill")
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                Color.clear
                    .font(.largeTitle)
                    .frame(width: 75, height: 75)
                    .animationOverlay(for: Int(viewModel.steps))
                Text("Astăzi")
                    .foregroundColor(.secondary)
                Text("Obiectiv 10.000")
                    .foregroundColor(.secondary)
            }
        }
        .onAppear {
            viewModel.loadSteps()
        }
    }
}

#Preview {
    StepCounterView()
}
