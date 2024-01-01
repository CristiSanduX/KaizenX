//
//  WaterAnimationView.swift
//  KaizenX
//
//  Created by Cristi Sandu on 01.01.2024.
//

import SwiftUI

struct WaterAnimationView: View {


    var body: some View {
        VStack {
            GeometryReader{proxy in
                
                let size = proxy.size
                
                ZStack {
                    Image(systemName: "drop.fill")
                        .resizable()
                        .renderingMode(/*@START_MENU_TOKEN@*/.template/*@END_MENU_TOKEN@*/)
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.gray)
                        .scaleEffect(x:1.1, y:1)
                    
                    WaterWave(progress: 1, waveHeight: 0.1, offset: size.width)
                        .fill(Color.blue)
                        .mask {
                            Image(systemName: "drop.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .padding(5)
                                
                        }
                }
                .frame(width: size.width, height: size.height, alignment: .center)
            }
            .frame(height: 350)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.white)
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
