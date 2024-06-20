import SwiftUI

struct AddExerciseView: View {
    @State private var name: String = ""
    @State private var sets: String = ""
    @State private var repetitions: String = ""
    @State private var weight: String = ""
    @Binding var selectedMuscleGroup: String
    @Binding var selectedDate: Date
    @Environment(\.presentationMode) var presentationMode

    var gymViewModel: GymCounterViewModel  // Variabila pasată din GymCounterView
    @Binding var predefinedExercise: PredefinedExercise?

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Detalii Exercițiu")) {
                    TextField("Nume exercițiu", text: $name)
                        .onAppear {
                            if let exercise = predefinedExercise {
                                name = exercise.name
                                selectedMuscleGroup = exercise.muscleGroup
                            }
                        }

                    Picker("Grupă musculară", selection: $selectedMuscleGroup) {
                        ForEach(gymViewModel.muscleGroups, id: \.self) { group in
                            Text(group).tag(group)
                                
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }

                Section(header: Text("Detalii Seturi și Greutate")) {
                    TextField("Număr de serii", text: $sets)
                        .keyboardType(.numberPad)

                    TextField("Număr de repetări", text: $repetitions)
                        .keyboardType(.numberPad)

                    TextField("Greutate (kg)", text: $weight)
                        .keyboardType(.decimalPad)
                }

                Button(action: {
                    if let setsInt = Int(sets), let repsInt = Int(repetitions), let weightInt = Int(weight) {
                        // Creăm un nou exercițiu cu datele introduse și data selectată
                        let newExercise = GymExercise(name: name, muscleGroup: selectedMuscleGroup, sets: setsInt, repetitions: repsInt, weight: weightInt, date: selectedDate)
                        gymViewModel.addExercise(newExercise, on: selectedDate)  // Pasăm exercițiul și data selectată la ViewModel pentru a fi adăugat
                        presentationMode.wrappedValue.dismiss()
                    }
                }) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
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
                .padding(.top, 20)
            }
            .navigationBarTitle("Adaugă exercițiu", displayMode: .inline)
        }
        .onDisappear {
            predefinedExercise = nil
        }
    }
}
