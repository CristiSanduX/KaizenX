//
//  ContainerView.swift
//  KaizenX
//
//  Created by Cristi Sandu on 25.10.2023.
//

// Funcționează ca un comutator între ecranul de pornire și conținutul principal
import SwiftUI

struct ContainerView: View {

    @State private var isSplashScreenView = true

    var body: some View {
        if !isSplashScreenView {
            RootView()
        }
        else {
            SplashScreenView(isPresented: $isSplashScreenView)
        }
    }
}

#Preview {
    ContainerView()
}
