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
            
            GymCounterView()
                .tabItem {
                    Label("Sală", systemImage: "dumbbell")
                }
            
            FoodTrackingView()
                .tabItem {
                    Label("Mâncare", systemImage: "fork.knife")
                }
            
            StepsView()
                .tabItem {
                    Label("Pași", systemImage: "figure.walk")
                }
            
            WaterCounterView()
                .tabItem {
                    Label("Apă", systemImage: "drop.fill")
                }
            
            
            RewardsView()
                .tabItem {
                    Label("Recompense", systemImage: "gift.fill")
                }
            
            StatisticsView()
                .tabItem {
                    Label("Statistici", systemImage: "chart.bar.fill")
                }
        }
        .accentColor(Color.darkRed)
        .colorScheme(.light)
    }
}

#Preview {
    MainView(showSignInView: .constant(false))
}
