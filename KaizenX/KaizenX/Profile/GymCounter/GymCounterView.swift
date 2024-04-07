import SwiftUI

struct GymCounterView: View {
    @StateObject var viewModel = GymCounterViewModel()
    @State private var showingAddExerciseView = false
    @State private var selectedDate = Date()
    
    var body: some View {
        NavigationView {
            VStack {
                Text("ANTRENAMENTUL TĂU")
                    .font(.custom("Rubik-VariableFont_wght", size: 25))
                    .foregroundColor(.accentColor)
                    .padding(.top, 20)
                    .padding(.bottom, 20)
                
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
                                Text("\(exercise.sets) seturi, \(exercise.repetitions) repetări, \(exercise.weight) kg")
                                
                            }
                        }
                    }
                }
                
                Button("Adaugă Exercițiu") {
                    showingAddExerciseView = true
                }
            }
            
            .onChange(of: selectedDate) { newDate in
                viewModel.fetchExercisesForDate(newDate)
            }
            .sheet(isPresented: $showingAddExerciseView) {
                AddExerciseView(selectedMuscleGroup: $viewModel.selectedMuscleGroup,
                                selectedDate: $selectedDate,
                                gymViewModel: viewModel)
            }
            
        }
        .onAppear {
            viewModel.fetchExercisesForDate(selectedDate)
        }
    }
}
