//
//  SplashScreenView.swift
//  KaizenX
//
//  Created by Cristi Sandu on 25.10.2023.
//

import SwiftUI

struct SplashScreenView: View {
    
    @Binding var isPresented: Bool
    
    // Definirea unor variabile de stare pentru animații.
    @State private var scale = CGSize(width: 0.8, height: 0.8)
    @State private var opacityL1 = 0.0
    @State private var opacityL2 = 0.0
    @State private var opacityLogo = 1.0
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            ZStack {
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
        .opacity(opacityLogo)
        .onAppear{
            
            // Mărește logo-ul de la 0.8x la 1x în 1.5 secunde
            withAnimation(.easeInOut(duration: 1.5)) {
                scale = CGSize(width: 1, height: 1)
                opacityL1 = 1.0
            }
            
            // Toggle pentru opacitate
            for i in 0..<5 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5 + Double(i)*0.2, execute: {
                    if opacityL2 == 0.0
                    {
                        opacityL2 = 1.0
                    }
                    else {
                        opacityL2 = 0.0
                    }
                })
            }
            
            // După 2.5 secunde, schimbă efectul de scalare și ascunde SplashScreenView
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
