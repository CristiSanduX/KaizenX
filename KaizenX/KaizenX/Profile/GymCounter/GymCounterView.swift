import SwiftUI

struct GymCounterView: View {
    @StateObject var viewModel = GymCounterViewModel()
    @State private var showingAddExerciseView = false
    @State private var selectedDate = Date()

    var body: some View {
        NavigationView {
            VStack {
                DatePicker(
                    "Alege data",
                    selection: $selectedDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(GraphicalDatePickerStyle())
                .padding()
                
                List {
                    Section(header: Text("Exerciții pentru data selectată")) {
                        ForEach(viewModel.exercises, id: \.id) { exercise in
                            HStack {
                                Text(exercise.name)
                                Spacer()
                                Text("\(exercise.sets) seturi, \(exercise.repetitions) repetări, \(String(format: "%.2f", exercise.weight)) kg")

                            }
                        }
                    }
                }
                
                Button("Adaugă Exercițiu") {
                    showingAddExerciseView = true
                }
            }
            .navigationTitle("Antrenament Sala")
            .onChange(of: selectedDate) { newDate in
                viewModel.fetchExercisesForDate(newDate)
            }
            .sheet(isPresented: $showingAddExerciseView) {
                // Aici pasăm toate legăturile necesare către AddExerciseView
                AddExerciseView(selectedMuscleGroup: $viewModel.selectedMuscleGroup,
                                selectedDate: $selectedDate,
                                gymViewModel: viewModel)
            }

        }
    }
}
