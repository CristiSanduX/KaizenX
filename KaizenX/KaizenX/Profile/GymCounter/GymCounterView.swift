import SwiftUI

struct GymCounterView: View {
    @StateObject var viewModel = GymCounterViewModel()
    @State private var showingAddExerciseView = false

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Selectează Grupa Musculară")) {
                    Picker("Grupa Musculară", selection: $viewModel.selectedMuscleGroup) {
                        ForEach(viewModel.muscleGroups, id: \.self) { group in
                            Text(group).tag(group)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Section(header: Text("Exerciții")) {
                    ForEach(viewModel.exercises) { exercise in
                        HStack {
                            Text(exercise.name)
                            Spacer()
                            // Aici poți adăuga mai multe detalii despre exercițiu
                        }
                    }
                }
                
                Button("Adaugă Exercițiu") {
                    showingAddExerciseView = true
                }
                
            }
            .navigationTitle("Antrenament Sala")

            .sheet(isPresented: $showingAddExerciseView) {
                AddExerciseView(gymViewModel: viewModel, selectedMuscleGroup: $viewModel.selectedMuscleGroup)
            }
        }
    }
}
