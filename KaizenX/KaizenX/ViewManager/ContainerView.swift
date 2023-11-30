//
//  ContainerView.swift
//  KaizenX
//
//  Created by Cristi Sandu on 25.10.2023.
//

import SwiftUI

/// `ContainerView` servește drept view-ul rădăcină care decide afișarea ecranului de pornire sau a conținutului principal al aplicației.
struct ContainerView: View {
    
    // Variabila de stare care determină dacă ecranul de splash ar trebui afișat.
    @State private var isSplashScreenView = true
    
    var body: some View {
        if isSplashScreenView {
            SplashScreenView(isPresented: $isSplashScreenView)
        } else {
            RootView()
        }
    }
}

#Preview {
    ContainerView()
}
