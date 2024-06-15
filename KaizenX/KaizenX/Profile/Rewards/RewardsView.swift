//
//  RewardsView.swift
//  KaizenX
//
//  Created by Cristi Sandu on 15.06.2024.
//

import SwiftUI

struct RewardsView: View {
    @StateObject private var viewModel = RewardsViewModel()
    @State private var selectedAchievement: Achievement? = nil
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    Text("Premiile Tale")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding()
                    
                    ForEach(viewModel.achievements) { achievement in
                        Button(action: {
                            withAnimation {
                                selectedAchievement = achievement
                            }
                        }) {
                            rewardCard(for: achievement)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .animation(.easeInOut, value: selectedAchievement)
                    }
                }
                .onAppear {
                    viewModel.checkAchievements()
                }
            }
            .navigationTitle("Recompense")
        }
    }
    
    @ViewBuilder
    private func rewardCard(for achievement: Achievement) -> some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text(achievement.title)
                        .font(.headline)
                    Text(achievement.description)
                        .font(.subheadline)
                        .lineLimit(2)
                        .truncationMode(.tail)
                    if achievement.isEarned, let date = achievement.achievedDate {
                        Text("Ultima realizare: \(viewModel.getAchievementDate(for: achievement))")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                Spacer()
                if achievement.isEarned {
                    Image(systemName: "medal.fill")
                        .foregroundColor(.yellow)
                } else {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(achievement.isEarned ? Color("darkRed").opacity(0.1) : Color.gray.opacity(0.1))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(achievement.isEarned ? Color("darkRed") : Color.gray, lineWidth: 1)
            )
            .padding(.horizontal)
            .padding(.vertical, 5)
            
            if selectedAchievement == achievement {
                VStack(alignment: .leading) {
                    Text(achievement.description)
                        .font(.body)
                        .padding(.bottom, 10)
                    
                    if achievement.isEarned, let date = achievement.achievedDate {
                        Text("Această realizare a fost obținută ultima dată pe \(viewModel.getAchievementDate(for: achievement)).")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 5)
                .padding(.horizontal)
            }
        }
    }
}

#Preview {
    RewardsView()
}
