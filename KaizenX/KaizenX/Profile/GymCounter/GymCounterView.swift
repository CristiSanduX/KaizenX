import SwiftUI

struct GymCounterView: View {
    @StateObject var viewModel = GymCounterViewModel()
    @State private var showingAddExerciseView = false

    var body: some View {
        NavigationView {
            List {
                
                Section(header: Text("Exerciții")) {
                    ForEach(viewModel.exercises) { exercise in
                        HStack {
                            Text(exercise.name)
                            Spacer()
                        }
                    }
                }
                
                Button("Adaugă Exercițiu") {
                    showingAddExerciseView = true
                }
                
            }
            .navigationTitle("Antrenament Sala")

            .sheet(isPresented: $showingAddExerciseView) {
                AddExerciseView(selectedMuscleGroup: $viewModel.selectedMuscleGroup, gymViewModel: viewModel)
            }
        }
        .onAppear() {
            viewModel.fetchExercisesForToday()
        }
    }
        
}
