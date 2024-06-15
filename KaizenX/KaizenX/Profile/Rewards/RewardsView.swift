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
                    
                    
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 20)], spacing: 20) {
                        ForEach(viewModel.achievements) { achievement in
                            Button(action: {
                                withAnimation {
                                    selectedAchievement = achievement
                                }
                            }) {
                                rewardCard(for: achievement)
                                    .frame(width: 150, height: 150)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .animation(.easeInOut, value: selectedAchievement)
                        }
                    }
                    .padding()
                }
                .onAppear {
                    viewModel.checkAchievements()
                }
            }
            .navigationTitle("Recompense")
        }
        .sheet(item: $selectedAchievement) { achievement in
            RewardDetailView(achievement: achievement)
        }
    }
    
    @ViewBuilder
    private func rewardCard(for achievement: Achievement) -> some View {
        VStack {
            Image(systemName: achievement.isEarned ? "medal.fill" : "lock.fill")
                .resizable()
                .scaledToFit()
                .frame(height: 50)
                .foregroundColor(achievement.isEarned ? achievement.difficulty.color : .gray)
            Text(achievement.title)
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding(.bottom, 2)
                .lineLimit(2)
                .minimumScaleFactor(0.5)
            if achievement.isEarned, let date = achievement.achievedDate {
                Text("Ultima realizare:\n\(viewModel.getAchievementDate(for: achievement))")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding()
        .background(achievement.isEarned ? Color("darkRed").opacity(0.2) : Color.gray.opacity(0.2))
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}

struct RewardDetailView: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: 20) {
            Text(achievement.title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            Text(achievement.description)
                .font(.title2)
                .padding()
            if achievement.isEarned, let date = achievement.achievedDate {
                Text("Această realizare a fost obținută ultima dată pe \(date, formatter: DateFormatter.fullDateFormatter).")
                    .font(.body)
                    .padding()
            } else {
                Text("Această realizare nu a fost obținută încă.")
                    .font(.body)
                    .padding()
            }
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 10)
        .padding()
    }
}

extension DateFormatter {
    static var fullDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter
    }
}

#Preview {
    RewardsView()
}
