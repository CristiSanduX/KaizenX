//
//  AnimationNumber.swift
//  KaizenX
//
//  Created by Cristi Sandu on 21.03.2024.
//

import SwiftUI

// Structura pentru a crea un modificator animat pentru un număr
struct AnimatableNumber: AnimatableModifier {
    var animatableData: Int
    
    init(animatableData: Int) {
        self.animatableData = animatableData
    }
    
    func body(content: Content) -> some View {
        content
            .overlay(
                Text("\(animatableData)")
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .font(.largeTitle)
            )
    }
}

// Extensie pentru View pentru a adăuga un modificator animat
extension View {
    func animation(for number: Int) -> some View {
        modifier(AnimatableNumber(animatableData: number))
    }
}

// View-ul principal pentru animarea numărului de pași
struct AnimationNumber: View {
    @StateObject private var viewModel = ProfileViewModel() // ViewModel pentru gestionarea datelor utilizatorului
    
    var body: some View {
        ZStack {
            // Cerc exterior
            Circle()
                .stroke(style: .init(lineWidth: 8, lineCap: .round, lineJoin: .round))
                .foregroundColor(Color(.systemGray4))
                .frame(width: 220, height: 220)
                .overlay(
                    CSXShape()
                        .stroke(style: .init(lineWidth: 2, lineCap: .round, lineJoin: .round))
                        .foregroundColor(.accentColor)
                        .frame(width: 100, height: 100)
                )
            
            // Cerc progres
            Circle()
                .trim(from: 0, to: CGFloat(viewModel.steps / 10000))
                .stroke(style: .init(lineWidth: 8, lineCap: .round, lineJoin: .round))
                .foregroundColor(.accentColor)
                .frame(width: 220, height: 220)
                .rotationEffect(.degrees(-90))
                .shadow(radius: 5)
            
            // Detalii progres
            VStack {
                Image(systemName: "shoeprints.fill")
                    .font(.largeTitle)
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
    AnimationNumber()
}

// Forma personalizată pentru desenarea elementelor vizuale
struct CSXShape: Shape {
    func path(in rect: CGRect) -> Path {
        let length: CGFloat = min(rect.width, rect.height)
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let min = CGPoint(x: rect.minX, y: rect.minY)
        let max = CGPoint(x: rect.maxX, y: rect.maxY)
        
        var path = Path()
        
        // Linie sus
        path.move(to: CGPoint(x: center.x, y: min.y - length * 0.85))
        path.addLine(to: CGPoint(x: center.x, y: min.y - length * 0.70))
        
        // Linie jos
        path.move(to: CGPoint(x: center.x, y: max.y + length * 0.85))
        path.addLine(to: CGPoint(x: center.x, y: max.y + length * 0.70))
        
        // Linie stânga
        path.move(to: CGPoint(x: min.x - length * 0.85, y: center.y))
        path.addLine(to: CGPoint(x: min.x - length * 0.70, y: center.y))
        
        // Linie dreapta
        path.move(to: CGPoint(x: max.x + length * 0.85, y: center.y))
        path.addLine(to: CGPoint(x: max.x + length * 0.70, y: center.y))
        
        return path
            .strokedPath(.init(lineWidth: 2.5))
    }
}
