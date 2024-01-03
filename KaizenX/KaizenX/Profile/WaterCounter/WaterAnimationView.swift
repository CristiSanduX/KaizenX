//
//  WaterAnimationView.swift
//  KaizenX
//
//  Created by Cristi Sandu on 01.01.2024.
//

import SwiftUI

struct WaterAnimationView: View {
    var waterIntakeGoal: Double
    @Binding var waterIntake: Double

        var progress: CGFloat {
            CGFloat(waterIntake / waterIntakeGoal)
        }
    @State var startAnimation: CGFloat = 0
    



    var body: some View {
        
            GeometryReader{proxy in
                
                let size = proxy.size
                
                ZStack {
                    Image(systemName: "drop.fill")
                        .resizable()
                        .renderingMode(/*@START_MENU_TOKEN@*/.template/*@END_MENU_TOKEN@*/)
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.gray)
                        .scaleEffect(x:1.1, y:1)
                        .offset(y: -1)
                    
                    WaterWave(progress: progress, waveHeight: 0.1, offset: startAnimation)
                        .fill(Color.blue)
                    // Stropi de apă
                        .overlay(content: {
                            Circle()
                                .fill(.opacity(0.1))
                                .frame(width: 15, height: 15)
                                .offset(x: -20)
                            Circle()
                                .fill(.opacity(0.1))
                                .frame(width: 15, height: 15)
                                .offset(x: 40, y: 30)
                            Circle()
                                .fill(.opacity(0.1))
                                .frame(width: 25, height: 25)
                                .offset(x: -30, y: 80)
                            Circle()
                                .fill(.opacity(0.1))
                                .frame(width: 25, height: 25)
                                .offset(x: 50, y: 70)
                            Circle()
                                .fill(.opacity(0.1))
                                .frame(width: 10, height: 10)
                                .offset(x: -40, y: 50)
                            Circle()
                                .fill(.opacity(0.1))
                                .frame(width: 10, height: 10)
                                .offset(x: 40, y: 10)
                                    
                        })
                        .mask {
                            Image(systemName: "drop.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .padding(3)
                                
                        }
                        .overlay(alignment: .bottom) {
                            Button(action: {
                            }, label: {
                                Image(systemName: "plus")
                                    .font(.system(size: 25, weight: .black))
                                    .foregroundColor(.blue)
                                    .shadow(radius:2)
                                    .padding(15)
                                    .background(.white, in: Circle())
                            })
                            .offset(y: 40)
                        }
                }
                .frame(width: size.width, height: size.height, alignment: .center)
                .onAppear{
                                    withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                                        startAnimation = size.width
                                    }
                            }

            }
            .frame(height: 350)
        }


}

struct WaterWave: Shape {
    
    var progress: CGFloat
    var waveHeight: CGFloat
    
    // Animația inițială
    var offset: CGFloat
    
    var animatableData: CGFloat{
        get{offset}
        set{offset = newValue}
    }
    
    func path(in rect: CGRect) -> Path {
        return Path{path in
            
            path.move(to: .zero)
            
            let progressHeight: CGFloat = (1 - progress) * rect.height
            let height = waveHeight * rect.height
            
            for value in stride(from: 0, to: rect.width, by: 2) {
                let x: CGFloat = value
                let sine: CGFloat = sin(Angle(degrees: value+offset).radians)
                let y: CGFloat = progressHeight + (height * sine)
                
                path.addLine(to: CGPoint(x: x, y: y))
            }
            
            // Partea de jos
            path.addLine(to: CGPoint(x: rect.width, y: rect.height))
            path.addLine(to: CGPoint(x: 0, y: rect.height))

        }
    }
}

