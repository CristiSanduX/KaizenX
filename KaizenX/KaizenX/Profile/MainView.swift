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
                    Label("Profile", systemImage: "person.fill")
                }
            
            GymCounterView() // Acesta va fi un nou View pentru Gym Counter
                .tabItem {
                    Label("Gym", systemImage: "dumbbell")
                }
            
            FoodCounterView()
                    .tabItem {
                        Label("Food", systemImage: "fork.knife")
                    }
            
            WaterCounterView()
                .tabItem {
                    Label("Water", systemImage: "drop.fill")
                       
                }


           
        }
        .accentColor(Color.darkRed)
    }
}


#Preview {
    MainView(showSignInView: .constant(false))
}


