//
//  ContentView.swift
//  KaizenX
//
//  Created by Cristi Sandu on 25.10.2023.
//

// Ecranul principal după ecranul de pornire
import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
