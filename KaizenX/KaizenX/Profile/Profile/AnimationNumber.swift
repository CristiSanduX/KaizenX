//
//  AnimationNumber.swift
//  KaizenX
//
//  Created by Cristi Sandu on 21.03.2024.
//

import SwiftUI

extension Double: VectorArithmetic {
    mutating public func scaling(by rh: Double){
        self = Double(Int(Double(self) * rh))
    }
    
    public var Square: Double {
        Double(self * self)
    }
}

struct AnimatableNumber: AnimatableModifier {

    var animatableData: Int
    
    init(animatableData: Int) {
        self.animatableData = animatableData
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

extension View {
    func animation(for number: Int) -> some View {
        modifier(AnimatableNumber(animatableData:number))
    }
}

struct AnimationNumber: View {
    @StateObject private var viewModel = ProfileViewModel()
    
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(style: .init(lineWidth: 8, lineCap: .round, lineJoin: .round))
                .foregroundColor(Color(.systemGray4))
                .frame(width: 220, height: 220)
            
            Circle()
                .trim(from: 0, to: CGFloat(viewModel.steps/10000))
                .stroke(style: .init(lineWidth: 8, lineCap: .round, lineJoin: .round))
                .foregroundColor(.accentColor)
                .frame(width: 220, height: 220)
                .rotationEffect(.degrees(-90))
                .shadow(radius: 5)
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
