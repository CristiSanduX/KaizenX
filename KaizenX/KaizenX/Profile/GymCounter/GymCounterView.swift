import SwiftUI

struct GymCounterView: View {
    @StateObject var viewModel = GymCounterViewModel()
    @State private var showingAddExerciseView = false
    @State private var showingPredefinedExerciseView = false
    @State private var selectedDate = Date()
    
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
                
                if viewModel.exercises.isEmpty {
                    Text("Nu există exerciții pentru data selectată.")
                        .foregroundColor(.gray)
                } else {
                    List {
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
                            }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                    .frame(maxHeight: 500) 
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
                        PredefinedExercisesView(selectedDate: $selectedDate, gymViewModel: viewModel)
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
                        AddExerciseView(selectedMuscleGroup: $viewModel.selectedMuscleGroup,
                                        selectedDate: $selectedDate,
                                        gymViewModel: viewModel)
                    }
                }
                .background(Color(.systemGray6).edgesIgnoringSafeArea(.all))
                .onChange(of: selectedDate) { newDate in
                    viewModel.fetchExercisesForDate(newDate)
                }
                .onAppear {
                    viewModel.fetchExercisesForDate(selectedDate)
                }
            }
        }
    }
}
