//
//  StepCounterView.swift
//  KaizenX
//
//  Created by Cristi Sandu on 21.03.2024.
//

import SwiftUI

extension Int: VectorArithmetic {
    mutating public func scale(by rhs: Double) {
        self = Int(Double(self) * rhs)
    }
    
    public var magnitudeSquared: Double {
        Double(self * self)
    }
}

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

extension View {
    func animationOverlay(for number: Int) -> some View {
        modifier(AnimatableNumber(animatableData: number))
    }
}

struct StepCounterView: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    StepCounterView()
}
