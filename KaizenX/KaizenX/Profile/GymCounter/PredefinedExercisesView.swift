import SwiftUI

let muscleGroupIcons: [String: String] = [
    "Piept":        "figure.strengthtraining.traditional", // bench-press silueta
    "Spate":        "figure.archery",                       // tragere arc → lats
    "Biceps":       "dumbbell.fill",                        // gantera → curl
    "Triceps":      "figure.cross.training",                // overhead → triceps
    "Picioare":     "figure.strengthtraining.functional",   // pozitie squat / kettlebell
    "Umeri/Trapez": "figure.arms.open",                     // umeri largi
    "Abdomen":      "figure.core.training"                  // core / plank
]

struct PredefinedExercisesView: View {
    @Binding var selectedDate: Date
    @ObservedObject var gymViewModel: GymCounterViewModel
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedPredefinedExercise: PredefinedExercise?
    @State private var exerciseForDetails: PredefinedExercise? = nil

    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Alege grupa musculară")
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 4)

                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(gymViewModel.muscleGroups, id: \.self) { group in
                            let count = gymViewModel.predefinedExercises.filter { $0.muscleGroup == group }.count
                            NavigationLink {
                                ExerciseListView(
                                    muscleGroup: group,
                                    exercises: gymViewModel.predefinedExercises.filter { $0.muscleGroup == group },
                                    selectedPredefinedExercise: $selectedPredefinedExercise,
                                    exerciseForDetails: $exerciseForDetails,
                                    onSelect: { dismiss() }
                                )
                            } label: {
                                MuscleGroupCard(muscleGroup: group, count: count)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(20)
            }
            .background(Color(.systemGray6).ignoresSafeArea())
            .navigationTitle("Exerciții predefinite")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(item: $exerciseForDetails) { exercise in
            ExerciseDetailView(exercise: exercise)
        }
    }
}

// MARK: - Muscle group card (premium gradient)

private struct MuscleGroupCard: View {
    let muscleGroup: String
    let count: Int

    private var color: Color { Color.muscleColor(muscleGroup) }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.25))
                        .frame(width: 44, height: 44)
                    Image(systemName: muscleGroupIcons[muscleGroup] ?? "dumbbell.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.white)
                }
                Spacer()
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.white.opacity(0.7))
                    .padding(8)
                    .background(.white.opacity(0.15))
                    .clipShape(Circle())
            }

            Spacer(minLength: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(muscleGroup)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.white)
                Text("\(count) \(count == 1 ? "exercițiu" : "exerciții")")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.75))
            }
        }
        .padding(16)
        .frame(height: 140)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [color, color.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: color.opacity(0.25), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Exercise list

struct ExerciseListView: View {
    let muscleGroup: String
    let exercises: [PredefinedExercise]
    @Binding var selectedPredefinedExercise: PredefinedExercise?
    @Binding var exerciseForDetails: PredefinedExercise?
    var onSelect: () -> Void

    private var color: Color { Color.muscleColor(muscleGroup) }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Hero header with muscle color
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(.white.opacity(0.2))
                            .frame(width: 56, height: 56)
                        Image(systemName: muscleGroupIcons[muscleGroup] ?? "dumbbell.fill")
                            .font(.system(size: 26, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text(muscleGroup)
                            .font(.title3.weight(.bold))
                            .foregroundStyle(.white)
                        Text("\(exercises.count) \(exercises.count == 1 ? "exercițiu" : "exerciții")")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.85))
                    }
                    Spacer()
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    LinearGradient(
                        colors: [color, color.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: color.opacity(0.25), radius: 8, x: 0, y: 4)

                if exercises.isEmpty {
                    Text("Niciun exercițiu disponibil")
                        .foregroundStyle(.secondary)
                        .padding(.top, 40)
                } else {
                    VStack(spacing: 10) {
                        ForEach(exercises) { exercise in
                            ExerciseListRow(
                                exercise: exercise,
                                color: color,
                                icon: muscleGroupIcons[muscleGroup] ?? "dumbbell.fill",
                                onInfo: { exerciseForDetails = exercise },
                                onTap: {
                                    selectedPredefinedExercise = exercise
                                    onSelect()
                                }
                            )
                        }
                    }
                }
            }
            .padding(20)
        }
        .background(Color(.systemGray6).ignoresSafeArea())
        .navigationTitle(muscleGroup)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct ExerciseListRow: View {
    let exercise: PredefinedExercise
    let color: Color
    let icon: String
    var onInfo: () -> Void
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(color.opacity(0.12))
                        .frame(width: 44, height: 44)
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(color)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(exercise.name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                    Text("Apasă pentru a adăuga")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button(action: onInfo) {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(color.opacity(0.6))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Color helper (used everywhere in gym)

extension Color {
    static func muscleColor(_ group: String) -> Color {
        switch group {
        case "Piept":        return Color(red: 0.20, green: 0.55, blue: 0.95) // vibrant blue
        case "Spate":        return Color(red: 0.55, green: 0.35, blue: 0.85) // purple
        case "Biceps":       return Color(red: 0.95, green: 0.55, blue: 0.20) // orange
        case "Triceps":      return Color(red: 0.92, green: 0.30, blue: 0.30) // red
        case "Picioare":     return Color(red: 0.25, green: 0.75, blue: 0.45) // green
        case "Umeri/Trapez": return Color(red: 0.20, green: 0.75, blue: 0.85) // cyan
        case "Abdomen":      return Color(red: 0.95, green: 0.75, blue: 0.20) // golden yellow
        default:             return .gray
        }
    }
}
