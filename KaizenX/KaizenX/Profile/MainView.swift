//
//  MainView.swift
//  KaizenX
//
//  Created by Cristi Sandu on 23.12.2023.
//
import SwiftUI

struct MainView: View {
    @Binding var showSignInView: Bool
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            ProfileView(showSignInview: $showSignInView)
                .tabItem { Label("Profil", systemImage: "person.fill") }
                .tag(0)

            GymCounterView()
                .tabItem { Label("Sală", systemImage: "dumbbell") }
                .tag(1)

            WaterCounterView()
                .tabItem { Label("Apă", systemImage: "drop.fill") }
                .tag(2)

            StepsView()
                .tabItem { Label("Pași", systemImage: "figure.walk") }
                .tag(3)

            FoodTrackingView()
                .tabItem { Label("Mâncare", systemImage: "fork.knife") }
                .tag(4)

            RewardsView()
                .tabItem { Label("Recompense", systemImage: "gift.fill") }
                .tag(5)

            StatisticsView()
                .tabItem { Label("Statistici", systemImage: "chart.bar.fill") }
                .tag(6)
        }
        .tint(selectedTab == 2 ? .blue : Color.darkRed)
        .colorScheme(.light)
    }
}

#Preview {
    MainView(showSignInView: .constant(false))
}
