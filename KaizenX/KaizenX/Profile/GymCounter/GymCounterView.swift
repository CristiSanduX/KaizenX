//
//  GymCounterView.swift
//  KaizenX
//
//  Created by Cristi Sandu on 23.12.2023.
//

import SwiftUI
import HealthKit
import PDFKit

extension HKWorkoutActivityType {
    var activityName: String {
        switch self {
        case .traditionalStrengthTraining: return "Antrenament de forță"
        case .running:                     return "Alergare"
        case .cycling:                     return "Ciclism"
        case .swimming:                    return "Înot"
        case .walking:                     return "Mers"
        default:                           return "Altele"
        }
    }
    var activityIcon: String {
        switch self {
        case .traditionalStrengthTraining: return "dumbbell.fill"
        case .running:                     return "figure.run"
        case .cycling:                     return "bicycle"
        case .swimming:                    return "figure.pool.swim"
        case .walking:                     return "figure.walk"
        default:                           return "heart.fill"
        }
    }
}

struct GymCounterView: View {
    @StateObject var viewModel = GymCounterViewModel()
    @State private var selectedDate = Date()
    @State private var weekOffset = 0
    @State private var showingAddExerciseView = false
    @State private var showingPredefinedExerciseView = false
    @State private var selectedPredefinedExercise: PredefinedExercise? = nil

    private static let headerFormatter: DateFormatter = {
        let f = DateFormatter(); f.locale = Locale(identifier: "ro_RO")
        f.dateFormat = "d MMMM yyyy"; return f
    }()

    private var daysInWeek: [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let startOfWeek = calendar.date(byAdding: .day, value: weekOffset * 7, to: today)!
        let weekday = calendar.component(.weekday, from: startOfWeek)
        let mondayOffset = (weekday == 1 ? -6 : 2 - weekday)
        let monday = calendar.date(byAdding: .day, value: mondayOffset, to: startOfWeek)!
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: monday) }
    }

    private func isSameDay(_ a: Date, _ b: Date) -> Bool {
        Calendar.current.isDate(a, inSameDayAs: b)
    }

    private var totalVolume: Int {
        viewModel.exercises.reduce(0) { $0 + ($1.sets * $1.repetitions * $1.weight) }
    }
    private var totalSets: Int {
        viewModel.exercises.reduce(0) { $0 + $1.sets }
    }
    private var totalReps: Int {
        viewModel.exercises.reduce(0) { $0 + ($1.sets * $1.repetitions) }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    headerSection
                    weekStripSection
                    if !viewModel.exercises.isEmpty {
                        heroSummaryCard
                    }
                    exercisesSection
                    workoutsSection
                    addButtonsSection
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
            .background(Color(.systemGray6).ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
        }
        .onChange(of: selectedDate) { _, date in
            viewModel.fetchExercisesForDate(date)
            viewModel.fetchWorkoutsForDate(date)
        }
        .onAppear {
            viewModel.requestAuthorization()
            viewModel.fetchExercisesForDate(selectedDate)
            viewModel.fetchWorkoutsForDate(selectedDate)
        }
        .sheet(isPresented: $showingPredefinedExerciseView) {
            PredefinedExercisesView(
                selectedDate: $selectedDate,
                gymViewModel: viewModel,
                selectedPredefinedExercise: $selectedPredefinedExercise
            )
        }
        .sheet(isPresented: $showingAddExerciseView) {
            AddExerciseView(
                selectedMuscleGroup: $viewModel.selectedMuscleGroup,
                selectedDate: $selectedDate,
                gymViewModel: viewModel,
                predefinedExercise: .constant(nil)
            )
        }
        .sheet(item: $selectedPredefinedExercise) { exercise in
            AddExerciseView(
                selectedMuscleGroup: $viewModel.selectedMuscleGroup,
                selectedDate: $selectedDate,
                gymViewModel: viewModel,
                predefinedExercise: .constant(exercise)
            )
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 4) {
            Text("Antrenamentul tău")
                .font(.title2.weight(.semibold))
            Text(Self.headerFormatter.string(from: selectedDate))
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 8)
    }

    // MARK: - Week strip

    private var weekStripSection: some View {
        VStack(spacing: 10) {
            HStack {
                Button { withAnimation { weekOffset -= 1 } } label: {
                    Image(systemName: "chevron.left")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.darkRed)
                        .frame(width: 28, height: 28)
                }
                Spacer()
                Button { withAnimation { weekOffset = 0; selectedDate = Date() } } label: {
                    Text("Azi")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Calendar.current.isDateInToday(selectedDate) ? .secondary : Color.darkRed)
                }
                Spacer()
                Button { withAnimation { weekOffset += 1 } } label: {
                    Image(systemName: "chevron.right")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.darkRed)
                        .frame(width: 28, height: 28)
                }
            }
            .padding(.horizontal, 4)

            HStack(spacing: 6) {
                ForEach(daysInWeek, id: \.self) { day in
                    DayCell(day: day, isSelected: isSameDay(day, selectedDate), isToday: Calendar.current.isDateInToday(day))
                        .onTapGesture { withAnimation(.easeInOut(duration: 0.2)) { selectedDate = day } }
                }
            }
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Hero summary card

    private var heroSummaryCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("VOLUM TOTAL")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.7))
                    .tracking(1)

                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text("\(totalVolume)")
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .contentTransition(.numericText())
                    Text("kg")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.8))
                }
            }

            HStack(spacing: 0) {
                HeroMiniStat(value: "\(viewModel.exercises.count)", label: "exerciții")
                Divider().frame(height: 36).overlay(Color.white.opacity(0.2))
                HeroMiniStat(value: "\(totalSets)", label: "seturi")
                Divider().frame(height: 36).overlay(Color.white.opacity(0.2))
                HeroMiniStat(value: "\(totalReps)", label: "repetări")
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [Color.darkRed, Color.darkRed.opacity(0.75)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.darkRed.opacity(0.25), radius: 12, x: 0, y: 6)
    }

    // MARK: - Exercises

    @ViewBuilder
    private var exercisesSection: some View {
        if viewModel.exercises.isEmpty {
            emptyState
        } else {
            VStack(alignment: .leading, spacing: 10) {
                Text("Exerciții")
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(.secondary)

                ForEach(viewModel.exercises) { exercise in
                    ExerciseRow(exercise: exercise) {
                        viewModel.deleteExercise(exercise, on: selectedDate)
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.darkRed.opacity(0.08))
                    .frame(width: 84, height: 84)
                Image(systemName: "dumbbell.fill")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundStyle(Color.darkRed.opacity(0.6))
            }

            VStack(spacing: 4) {
                Text("Niciun exercițiu")
                    .font(.headline)
                Text(Calendar.current.isDateInToday(selectedDate)
                     ? "Adaugă primul tău exercițiu pentru azi"
                     : "Niciun antrenament pentru această zi")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
    }

    // MARK: - Apple Watch workouts

    private var workoutsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Apple Watch")
                .font(.footnote.weight(.medium))
                .foregroundStyle(.secondary)

            if viewModel.workoutsForSelectedDate.isEmpty {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.systemGray5))
                            .frame(width: 36, height: 36)
                        Image(systemName: "applewatch")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                    Text("Niciun antrenament înregistrat")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                ForEach(viewModel.workoutsForSelectedDate, id: \.uuid) { workout in
                    WorkoutRow(workout: workout)
                }
            }
        }
    }

    // MARK: - Add buttons

    private var addButtonsSection: some View {
        VStack(spacing: 10) {
            HStack(spacing: 12) {
                Button { showingPredefinedExerciseView = true } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "list.bullet")
                            .font(.subheadline.weight(.semibold))
                        Text("Predefinit")
                            .font(.subheadline.weight(.semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color(.secondarySystemGroupedBackground))
                    .foregroundStyle(Color.darkRed)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.darkRed.opacity(0.3), lineWidth: 1))
                }

                Button { showingAddExerciseView = true } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "plus")
                            .font(.subheadline.weight(.semibold))
                        Text("Exercițiu nou")
                            .font(.subheadline.weight(.semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.darkRed)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .shadow(color: Color.darkRed.opacity(0.3), radius: 6, x: 0, y: 3)
                }
            }

            Button { exportData() } label: {
                HStack(spacing: 8) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.subheadline.weight(.medium))
                    Text("Exportă antrenament")
                        .font(.subheadline.weight(.medium))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color(.secondarySystemGroupedBackground))
                .foregroundStyle(.secondary)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
    }

    // MARK: - Export PDF

    private func exportData() {
        let pdfDocument = PDFDocument()
        let pageBounds = CGRect(x: 0, y: 0, width: 8.5 * 72.0, height: 11 * 72.0)
        let renderer = UIGraphicsImageRenderer(bounds: pageBounds)
        let img = renderer.image { ctx in
            UIColor.white.setFill(); ctx.fill(pageBounds)
            let title = "Antrenament - \(selectedDate.formatted(date: .numeric, time: .omitted))\n\n"
            title.draw(at: CGPoint(x: 20, y: 20), withAttributes: [.font: UIFont.boldSystemFont(ofSize: 20)])
            var y: CGFloat = 60
            for exercise in viewModel.exercises {
                let text = "\(exercise.name) — \(exercise.muscleGroup)\n\(exercise.sets) seturi × \(exercise.repetitions) rep × \(exercise.weight) kg\n\n"
                text.draw(at: CGPoint(x: 20, y: y), withAttributes: [.font: UIFont.systemFont(ofSize: 12)])
                y += 40
            }
        }
        if let page = PDFPage(image: img) { pdfDocument.insert(page, at: 0) }
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Antrenament_\(selectedDate.formatted(date: .numeric, time: .omitted)).pdf")
        pdfDocument.write(to: url)
        let vc = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let root = scene.windows.first?.rootViewController {
            root.present(vc, animated: true)
        }
    }
}

// MARK: - Hero mini stat

private struct HeroMiniStat: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.title3.weight(.bold))
                .foregroundStyle(.white)
                .contentTransition(.numericText())
            Text(label)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Day Cell

private struct DayCell: View {
    let day: Date
    let isSelected: Bool
    let isToday: Bool

    private static let dayFormatter: DateFormatter = {
        let f = DateFormatter(); f.locale = Locale(identifier: "ro_RO")
        f.dateFormat = "EEE"; return f
    }()

    var body: some View {
        VStack(spacing: 4) {
            Text(Self.dayFormatter.string(from: day).prefix(2).uppercased())
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(isSelected ? .white : .secondary)
            Text(Calendar.current.component(.day, from: day).description)
                .font(.system(size: 15, weight: isSelected ? .bold : .regular))
                .foregroundStyle(isSelected ? .white : isToday ? Color.darkRed : .primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(isSelected ? Color.darkRed : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

// MARK: - Exercise Row

private struct ExerciseRow: View {
    let exercise: GymExercise
    let onDelete: () -> Void

    private var color: Color { Color.muscleColor(exercise.muscleGroup) }

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(color.opacity(0.12))
                    .frame(width: 42, height: 42)
                Image(systemName: muscleGroupIcons[exercise.muscleGroup] ?? "dumbbell.fill")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(color)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)

                HStack(spacing: 6) {
                    StatPill(value: "\(exercise.sets)", label: "seturi")
                    StatPill(value: "\(exercise.repetitions)", label: "rep")
                    StatPill(value: "\(exercise.weight)", label: "kg")
                }
            }

            Spacer()

            Button { onDelete() } label: {
                Image(systemName: "trash")
                    .font(.caption)
                    .foregroundStyle(.red.opacity(0.6))
                    .padding(8)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(color.opacity(0.15), lineWidth: 1)
        )
    }
}

private struct StatPill: View {
    let value: String
    let label: String

    var body: some View {
        HStack(spacing: 3) {
            Text(value)
                .font(.caption2.weight(.bold))
                .foregroundStyle(.primary)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 7)
        .padding(.vertical, 3)
        .background(Color(.systemGray6))
        .clipShape(Capsule())
    }
}

// MARK: - Workout Row

private struct WorkoutRow: View {
    let workout: HKWorkout

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(LinearGradient(colors: [.green.opacity(0.2), .green.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 42, height: 42)
                Image(systemName: workout.workoutActivityType.activityIcon)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(.green)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(workout.workoutActivityType.activityName)
                    .font(.subheadline.weight(.semibold))
                HStack(spacing: 6) {
                    StatPill(value: "\(Int(workout.duration / 60))", label: "min")
                    StatPill(value: "\(Int(workout.totalEnergyBurned?.doubleValue(for: .kilocalorie()) ?? 0))", label: "kcal")
                }
            }

            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.green.opacity(0.15), lineWidth: 1)
        )
    }
}
