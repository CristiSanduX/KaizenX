//
//  ProfileView.swift
//  KaizenX
//
//  Created by Cristi Sandu on 22.11.2023.
//

import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @Binding var showSignInview: Bool

    @State private var isImagePickerPresented = false
    @State private var selectedImage: UIImage?

    private var waterGoal: Double {
        let saved = UserDefaults.standard.double(forKey: "waterGoal")
        return saved > 0 ? saved : 2500
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Spacer()

                if let user = viewModel.user {
                    VStack(spacing: 32) {
                        avatarSection(user: user)
                        statsSection
                    }
                } else {
                    ProgressView()
                }

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGray6).ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        SettingsView(showSignInView: $showSignInview)
                    } label: {
                        Image(systemName: "gear")
                            .foregroundStyle(Color.darkRed)
                    }
                }
            }
        }
        .onAppear {
            Task {
                try? await viewModel.loadCurrentUser()
                viewModel.loadSteps()
                try? await viewModel.loadTodayWaterIntake()
            }
        }
        .sheet(isPresented: $isImagePickerPresented) {
            PhotoPicker(selectedImage: $selectedImage) {
                guard let img = selectedImage else { return }
                Task { try? await viewModel.uploadImageToStorage(img) }
            }
        }
    }

    // MARK: - Avatar

    private func avatarSection(user: DBUser) -> some View {
        VStack(spacing: 14) {
            ZStack(alignment: .bottomTrailing) {
                Group {
                    if let urlStr = user.photoURL, let url = URL(string: urlStr) {
                        AsyncImage(url: url) { image in
                            image.resizable().scaledToFill()
                        } placeholder: {
                            Color(.systemGray5)
                        }
                    } else {
                        Image(systemName: "person.fill")
                            .resizable()
                            .scaledToFit()
                            .padding(28)
                            .foregroundStyle(Color(.systemGray3))
                            .background(Color(.systemGray5))
                    }
                }
                .frame(width: 110, height: 110)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color(.systemGray4), lineWidth: 1))

                Button { isImagePickerPresented = true } label: {
                    ZStack {
                        Circle().fill(Color.darkRed).frame(width: 32, height: 32)
                        Image(systemName: "camera.fill")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                }
                .offset(x: 4, y: 4)
            }

            VStack(spacing: 4) {
                Text(viewModel.displayName)
                    .font(.title3.weight(.semibold))
                if let email = user.email {
                    Text(email)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    // MARK: - Stats

    private var statsSection: some View {
        HStack(spacing: 12) {
            ProfileStatCard(
                icon: "figure.walk",
                label: "Pași",
                value: String(format: "%d", Int(viewModel.steps)),
                goal: "din 10.000",
                progress: min(viewModel.steps / 10000, 1.0),
                color: viewModel.steps >= 10000 ? .green : .purple
            )
            ProfileStatCard(
                icon: "drop.fill",
                label: "Apă",
                value: formatWater(viewModel.waterIntake),
                goal: "din \(formatWater(waterGoal))",
                progress: min(viewModel.waterIntake / waterGoal, 1.0),
                color: viewModel.waterIntake >= waterGoal ? .green : .blue
            )
        }
        .padding(.horizontal, 20)
    }

    private func formatWater(_ ml: Double) -> String {
        let l = ml / 1000
        if l.truncatingRemainder(dividingBy: 1) == 0 { return "\(Int(l)) L" }
        if l.truncatingRemainder(dividingBy: 0.5) == 0 { return String(format: "%.1f L", l) }
        return String(format: "%.2f L", l)
    }
}

// MARK: - Stat Card

private struct ProfileStatCard: View {
    let icon: String
    let label: String
    let value: String
    let goal: String
    let progress: Double
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(color)
                Text(label)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
            }

            Text(value)
                .font(.title2.weight(.bold))
                .foregroundStyle(.primary)
                .contentTransition(.numericText())

            Text(goal)
                .font(.caption)
                .foregroundStyle(.secondary)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color(.systemGray5)).frame(height: 4)
                    Capsule().fill(color)
                        .frame(width: geo.size.width * progress, height: 4)
                        .animation(.easeInOut(duration: 0.5), value: progress)
                }
            }
            .frame(height: 4)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: - Legacy

struct StatCardView: View {
    let title: String; let progress: Double; let currentValue: Int; let goalValue: Int; let unit: String
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title).font(.headline).foregroundStyle(Color.darkRed)
            ProgressView(value: progress).progressViewStyle(LinearProgressViewStyle(tint: .blue))
            HStack {
                Text("\(currentValue) \(unit)"); Spacer()
                Text("Obiectiv: \(goalValue) \(unit)")
            }
            .font(.subheadline).foregroundStyle(.secondary)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 20).fill(Color(.systemGray6)))
        .shadow(radius: 5).padding(.horizontal)
    }
}

struct GymLocatorView: View {
    @StateObject private var locationManager = LocationManager()
    var body: some View {
        GoogleMapsView(locationManager: locationManager)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .frame(height: 400)
    }
}
