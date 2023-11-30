//
//  SplashScreenView.swift
//  KaizenX
//
//  Created by Cristi Sandu on 25.10.2023.
//

import SwiftUI

/// `SplashScreenView` este utilizat pentru a afișa un ecran de încărcare inițială (splash screen) când aplicația este lansată.
struct SplashScreenView: View {
    
    @Binding var isPresented: Bool
    
    // Variabile de stare pentru controlul animațiilor de scalare și opacitate.
    @State private var scale = CGSize(width: 0.8, height: 0.8)
    @State private var opacityL1 = 0.0
    @State private var opacityL2 = 0.0
    @State private var opacityLogo = 1.0
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea() // Fundal alb pentru splash screen
            
            ZStack {
                // Două imagini de logo care se schimbă în opacitate
                Image("Logo1")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
                    .opacity(opacityL1)
                
                Image("Logo2")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
                    .opacity(opacityL2)
            }
            .scaleEffect(scale)
        }
        .opacity(opacityLogo) // Opacitatea întregului ZStack
        .onAppear{
            
            // Mărește logo-ul de la 0.8x la 1x în 1.5 secunde
            withAnimation(.easeInOut(duration: 1.5)) {
                scale = CGSize(width: 1, height: 1)
                opacityL1 = 1.0
            }
            
            // Animații pentru alternarea opacității între cele două logo-uri
            for i in 0..<5 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5 + Double(i) * 0.2) {
                    opacityL2 = opacityL2 == 0.0 ? 1.0 : 0.0
                }
            }
            
            // Ascunde splash screen-ul după o anumită durată
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5, execute: {
                withAnimation(.easeIn(duration: 0.35)) {
                    scale = CGSize(width: 50, height: 50)
                    isPresented.toggle()
                }
            })
        }
    }
}

#Preview {
    SplashScreenView(isPresented: .constant(true))
}
