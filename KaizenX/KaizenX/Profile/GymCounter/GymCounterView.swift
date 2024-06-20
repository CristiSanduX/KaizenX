import SwiftUI
import HealthKit

extension HKWorkoutActivityType {
    var activityName: String {
        switch self {
        case .traditionalStrengthTraining:
            return "Traditional Strength Training"
        case .running:
            return "Running"
        case .cycling:
            return "Cycling"
        case .swimming:
            return "Swimming"
        case .walking:
            return "Walking"
        // Adăugați mai multe cazuri după necesitate
        default:
            return "Other"
        }
    }
}


struct GymCounterView: View {
    @StateObject var viewModel = GymCounterViewModel()
    @State private var showingAddExerciseView = false
    @State private var showingPredefinedExerciseView = false
    @State private var selectedDate = Date()
    @State private var selectedPredefinedExercise: PredefinedExercise? = nil

    var body: some View {
        NavigationView {
            VStack {
                Text("ANTRENAMENTUL TĂU")
                    .font(.custom("Rubik-VariableFont_wght", size: 25))
                    .foregroundColor(.accentColor)
                    .padding(.top, 20)
                    .padding(.bottom, 10)

                DatePicker(
                    "Alege data",
                    selection: $selectedDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(GraphicalDatePickerStyle())
                .padding()

                if viewModel.exercises.isEmpty && viewModel.workoutsForSelectedDate.isEmpty {
                    Text("Nu există exerciții sau antrenamente pentru data selectată.")
                        .foregroundColor(.gray)
                } else {
                    ScrollView {
                        VStack(alignment: .leading) {
                            if !viewModel.exercises.isEmpty {
                                Section(header: Text("Exerciții pentru data selectată").font(.headline).foregroundColor(.accentColor)) {
                                    ForEach(viewModel.exercises, id: \.id) { exercise in
                                        HStack {
                                            VStack(alignment: .leading) {
                                                Text(exercise.name)
                                                    .font(.body)
                                                    .foregroundColor(.primary)
                                                Text(exercise.muscleGroup)
                                                    .font(.subheadline)
                                                    .foregroundColor(.secondary)
                                            }
                                            Spacer()
                                            Text("\(exercise.sets) seturi, \(exercise.repetitions) repetări, \(exercise.weight) kg")
                                                .font(.body)
                                                .foregroundColor(.secondary)
                                        }
                                        .padding(.vertical, 5)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(8)
                                        .padding(.horizontal)
                                    }
                                }
                                .padding(.top)
                            }

                            if !viewModel.workoutsForSelectedDate.isEmpty {
                                Section(header: Text("Antrenamente din Apple Watch").font(.headline).foregroundColor(.accentColor)) {
                                    ForEach(viewModel.workoutsForSelectedDate, id: \.uuid) { workout in
                                        HStack {
                                            VStack(alignment: .leading) {
                                                Text(workout.workoutActivityType.activityName)
                                                    .font(.body)
                                                    .foregroundColor(.primary)
                                                Text("Durata: \(Int(workout.duration / 60)) min")
                                                    .font(.subheadline)
                                                    .foregroundColor(.secondary)
                                            }
                                            Spacer()
                                            Text("\(workout.totalEnergyBurned?.doubleValue(for: .kilocalorie()) ?? 0) kcal")
                                                .font(.body)
                                                .foregroundColor(.secondary)
                                        }
                                        .padding(.vertical, 5)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(8)
                                        .padding(.horizontal)
                                    }
                                }
                                .padding(.top)
                            }
                        }
                    }
                }

                Spacer()
                HStack {
                    Button(action: {
                        showingPredefinedExerciseView = true
                    }) {
                        HStack {
                            Image(systemName: "list.bullet")
                                .font(.headline)
                            Text("Alege Exercițiu Predefinit")
                                .font(.subheadline)
                                .fontWeight(.bold)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .foregroundColor(.white)
                        .background(Color.accentColor)
                        .cornerRadius(8)
                    }
                    .sheet(isPresented: $showingPredefinedExerciseView) {
                        PredefinedExercisesView(
                            selectedDate: $selectedDate,
                            gymViewModel: viewModel,
                            selectedPredefinedExercise: $selectedPredefinedExercise
                        )
                    }

                    Button(action: {
                        showingAddExerciseView = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .font(.headline)
                            Text("Adaugă Exercițiu")
                                .font(.subheadline)
                                .fontWeight(.bold)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .foregroundColor(.white)
                        .background(Color.accentColor)
                        .cornerRadius(8)
                    }
                    .padding(.bottom, 5)
                    .sheet(isPresented: $showingAddExerciseView) {
                        AddExerciseView(
                            selectedMuscleGroup: $viewModel.selectedMuscleGroup,
                            selectedDate: $selectedDate,
                            gymViewModel: viewModel,
                            predefinedExercise: .constant(nil)
                        )
                    }
                }
                .background(Color(.systemGray6).edgesIgnoringSafeArea(.all))
                .onChange(of: selectedDate) { newDate in
                    viewModel.fetchExercisesForDate(newDate)
                    viewModel.fetchWorkoutsForDate(newDate)
                }
                .onAppear {
                    viewModel.requestAuthorization()
                    viewModel.fetchExercisesForDate(selectedDate)
                    viewModel.fetchWorkoutsForDate(selectedDate)
                }
            }
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
}
