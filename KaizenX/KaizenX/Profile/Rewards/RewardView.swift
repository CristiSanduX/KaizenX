//
//  RewardView.swift
//  KaizenX
//
//  Created by Cristi Sandu on 13.06.2024.
//

import SwiftUI

struct RewardView: View {
    @StateObject private var viewModel = RewardViewModel()
    
    var body: some View {
        VStack {
            Text("Premii pentru pași")
                .font(.title)
                .padding()
            
            List(viewModel.stepRewards, id: \.self) { reward in
                Text(reward)
            }
            
            Text("Premii pentru hidratare")
                .font(.title)
                .padding()
            
            List(viewModel.hydrationRewards, id: \.self) { reward in
                Text(reward)
            }
        }
        .onAppear {
            Task {
                await viewModel.checkRewards()
            }
        }
    }
}

#Preview {
    RewardView()
}
