import SwiftUI

struct AddExerciseView: View {
    @State private var name: String = ""
    @State private var sets: Int = 3
    @State private var repetitions: Int = 10
    @State private var weight: Double = 20
    @Binding var selectedMuscleGroup: String
    @Binding var selectedDate: Date
    @Environment(\.dismiss) private var dismiss

    var gymViewModel: GymCounterViewModel
    @Binding var predefinedExercise: PredefinedExercise?

    private let isPredefined: Bool
    private let weightStep: Double = 2.5

    init(selectedMuscleGroup: Binding<String>, selectedDate: Binding<Date>, gymViewModel: GymCounterViewModel, predefinedExercise: Binding<PredefinedExercise?>) {
        self._selectedMuscleGroup = selectedMuscleGroup
        self._selectedDate = selectedDate
        self.gymViewModel = gymViewModel
        self._predefinedExercise = predefinedExercise
        self.isPredefined = predefinedExercise.wrappedValue != nil
    }

    private var canSave: Bool { !name.trimmingCharacters(in: .whitespaces).isEmpty }
    private var muscleColor: Color { Color.muscleColor(selectedMuscleGroup) }
    private var totalVolume: Int { sets * repetitions * Int(weight) }

    var body: some View {
        VStack(spacing: 0) {
            // Handle
            RoundedRectangle(cornerRadius: 3)
                .fill(Color(.systemGray4))
                .frame(width: 36, height: 5)
                .padding(.top, 12)
                .padding(.bottom, 16)

            ScrollView {
                VStack(spacing: 18) {
                    // HERO HEADER (gradient cu muscle color)
                    heroHeader

                    // Nume (doar dacă nu e predefinit)
                    if !isPredefined {
                        nameField
                    }

                    // Grupă musculară chips
                    muscleGroupChips

                    // Stepper rows
                    steppersCard

                    // Volume preview
                    volumePreview
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            }

            // Bottom action
            Button {
                let newExercise = GymExercise(
                    name: name,
                    muscleGroup: selectedMuscleGroup,
                    sets: sets,
                    repetitions: repetitions,
                    weight: Int(weight),
                    date: selectedDate
                )
                gymViewModel.addExercise(newExercise, on: selectedDate)
                dismiss()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.headline)
                    Text("Adaugă exercițiu")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(canSave ? muscleColor : Color(.systemGray4))
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .shadow(color: canSave ? muscleColor.opacity(0.35) : .clear, radius: 8, x: 0, y: 4)
                .animation(.easeInOut(duration: 0.2), value: canSave)
                .animation(.easeInOut(duration: 0.2), value: selectedMuscleGroup)
            }
            .disabled(!canSave)
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .padding(.bottom, 8)
            .background(Color(.systemGroupedBackground))
        }
        .background(Color(.systemGroupedBackground))
        .onAppear {
            if let exercise = predefinedExercise {
                name = exercise.name
                selectedMuscleGroup = exercise.muscleGroup
            }
        }
        .onDisappear { predefinedExercise = nil }
    }

    // MARK: - Hero header

    private var heroHeader: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(.white.opacity(0.22))
                    .frame(width: 64, height: 64)
                Image(systemName: muscleGroupIcons[selectedMuscleGroup] ?? "dumbbell.fill")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(.white)
            }

            VStack(spacing: 3) {
                Text(isPredefined ? name : (name.isEmpty ? "Exercițiu nou" : name))
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                Text(selectedMuscleGroup)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white.opacity(0.85))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 22)
        .background(
            LinearGradient(
                colors: [muscleColor, muscleColor.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: muscleColor.opacity(0.25), radius: 10, x: 0, y: 5)
        .animation(.easeInOut(duration: 0.25), value: selectedMuscleGroup)
    }

    // MARK: - Name field

    private var nameField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Nume exercițiu", systemImage: "pencil")
                .font(.footnote.weight(.medium))
                .foregroundStyle(.secondary)
            TextField("ex: Bench Press", text: $name)
                .font(.body)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - Muscle group chips

    private var muscleGroupChips: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Grupă musculară", systemImage: "figure.strengthtraining.traditional")
                .font(.footnote.weight(.medium))
                .foregroundStyle(.secondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(gymViewModel.muscleGroups, id: \.self) { group in
                        let isSelected = selectedMuscleGroup == group
                        let groupColor = Color.muscleColor(group)
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedMuscleGroup = group
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: muscleGroupIcons[group] ?? "dumbbell.fill")
                                    .font(.system(size: 11, weight: .semibold))
                                Text(group)
                                    .font(.subheadline.weight(isSelected ? .semibold : .regular))
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 9)
                            .background(isSelected ? groupColor : Color(.secondarySystemGroupedBackground))
                            .foregroundStyle(isSelected ? .white : .primary)
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(isSelected ? .clear : groupColor.opacity(0.25), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 1)
            }
        }
    }

    // MARK: - Steppers card

    private var steppersCard: some View {
        VStack(spacing: 0) {
            ExerciseStepperRow(label: "Serii", icon: "repeat", value: $sets, range: 1...20, step: 1, unit: "×", accent: muscleColor)
            Divider().padding(.leading, 48)
            ExerciseStepperRow(label: "Repetări", icon: "arrow.clockwise", value: $repetitions, range: 1...100, step: 1, unit: "rep", accent: muscleColor)
            Divider().padding(.leading, 48)
            ExerciseWeightRow(weight: $weight, step: weightStep, accent: muscleColor)
        }
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    // MARK: - Volume preview

    private var volumePreview: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(muscleColor.opacity(0.12))
                    .frame(width: 40, height: 40)
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(muscleColor)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("VOLUM TOTAL")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .tracking(0.8)
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(totalVolume)")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(muscleColor)
                        .contentTransition(.numericText())
                    Text("kg")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .animation(.easeInOut(duration: 0.2), value: totalVolume)
    }
}

// MARK: - Stepper row (Int)

private struct ExerciseStepperRow: View {
    let label: String
    let icon: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    let step: Int
    let unit: String
    let accent: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.secondary)
                .frame(width: 24)
                .padding(.leading, 14)

            Text(label)
                .font(.subheadline.weight(.medium))

            Spacer()

            HStack(spacing: 0) {
                Button { if value > range.lowerBound { value -= step } } label: {
                    Image(systemName: "minus")
                        .font(.system(size: 13, weight: .bold))
                        .frame(width: 36, height: 36)
                        .foregroundStyle(value > range.lowerBound ? accent : Color(.systemGray3))
                }

                Text("\(value) \(unit)")
                    .font(.subheadline.weight(.semibold))
                    .frame(minWidth: 64)
                    .multilineTextAlignment(.center)
                    .contentTransition(.numericText())

                Button { if value < range.upperBound { value += step } } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 13, weight: .bold))
                        .frame(width: 36, height: 36)
                        .foregroundStyle(value < range.upperBound ? accent : Color(.systemGray3))
                }
            }
            .padding(.trailing, 8)
        }
        .frame(height: 52)
    }
}

// MARK: - Weight row

private struct ExerciseWeightRow: View {
    @Binding var weight: Double
    let step: Double
    let accent: Color

    @State private var isEditing = false
    @State private var weightText = ""
    @FocusState private var isFocused: Bool

    private var formattedWeight: String {
        weight.truncatingRemainder(dividingBy: 1) == 0
            ? "\(Int(weight)) kg"
            : String(format: "%.1f kg", weight)
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "scalemass.fill")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.secondary)
                .frame(width: 24)
                .padding(.leading, 14)

            Text("Greutate")
                .font(.subheadline.weight(.medium))

            Spacer()

            HStack(spacing: 0) {
                if isEditing {
                    Button { commit() } label: {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .frame(width: 36, height: 36)
                            .foregroundStyle(accent)
                    }

                    TextField("0", text: $weightText)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.center)
                        .font(.subheadline.weight(.semibold))
                        .frame(minWidth: 74)
                        .focused($isFocused)
                        .tint(accent)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 4)
                        .background(accent.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 8))

                    Button { commit() } label: {
                        Text("OK")
                            .font(.subheadline.weight(.bold))
                            .frame(width: 36, height: 36)
                            .foregroundStyle(.white)
                            .background(accent)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .padding(.leading, 4)
                } else {
                    Button { if weight > 0 { weight = max(0, weight - step) } } label: {
                        Image(systemName: "minus")
                            .font(.system(size: 13, weight: .bold))
                            .frame(width: 36, height: 36)
                            .foregroundStyle(weight > 0 ? accent : Color(.systemGray3))
                    }

                    Button {
                        weightText = weight.truncatingRemainder(dividingBy: 1) == 0
                            ? "\(Int(weight))"
                            : String(format: "%.1f", weight)
                        isEditing = true
                        isFocused = true
                    } label: {
                        Text(formattedWeight)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.primary)
                            .frame(minWidth: 74)
                            .multilineTextAlignment(.center)
                            .contentTransition(.numericText())
                            .overlay(alignment: .bottom) {
                                Rectangle()
                                    .fill(accent.opacity(0.25))
                                    .frame(height: 1)
                                    .offset(y: 2)
                            }
                    }
                    .buttonStyle(.plain)

                    Button { weight += step } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 13, weight: .bold))
                            .frame(width: 36, height: 36)
                            .foregroundStyle(accent)
                    }
                }
            }
            .padding(.trailing, 8)
        }
        .frame(height: 52)
        .onChange(of: isFocused) { _, focused in
            if !focused && isEditing { commit() }
        }
    }

    private func commit() {
        let normalized = weightText.replacingOccurrences(of: ",", with: ".")
        if let value = Double(normalized), value >= 0 {
            weight = value
        }
        isEditing = false
        isFocused = false
    }
}
