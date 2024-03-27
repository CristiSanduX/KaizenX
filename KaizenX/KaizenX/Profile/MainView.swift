//
//  MainView.swift
//  KaizenX
//
//  Created by Cristi Sandu on 23.12.2023.
//

import SwiftUI

struct MainView: View {
    @Binding var showSignInView: Bool
    
    
    var body: some View {
        TabView {
            
            
            ProfileView(showSignInview: $showSignInView)
                .tabItem {
                    Label("Profil", systemImage: "person.fill")

                }
            
            
            GymCounterView() // Acesta va fi un nou View pentru Gym Counter
                .tabItem {
                    Label("Sală", systemImage: "dumbbell")
                }
            
            
            FoodCounterView()
                .tabItem {
                    Label("Mâncare", systemImage: "fork.knife")
                    
                }
            
            
            WaterCounterView()
                .tabItem {
                    Label("Apă", systemImage: "drop.fill")
                }
        }
        .accentColor(Color.darkRed)
        .colorScheme(.light)
        
    }
    
    
}



#Preview {
    MainView(showSignInView: .constant(false))
}


