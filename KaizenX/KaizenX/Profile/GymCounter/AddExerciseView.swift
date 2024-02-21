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

    
    var body: some View {
        Form {
            TextField("Nume exercițiu", text: $name)
            
            Picker("Grupă musculară", selection: $selectedMuscleGroup) {
                ForEach(gymViewModel.muscleGroups, id: \.self) { group in
                    Text(group).tag(group)
                }
            }
            .pickerStyle(MenuPickerStyle())
            
            TextField("Număr de serii", text: $sets)
                .keyboardType(.numberPad)
            
            TextField("Număr de repetări", text: $repetitions)
                .keyboardType(.numberPad)
            
            TextField("Greutate (kg)", text: $weight)
                .keyboardType(.decimalPad)
            
            Button("Adaugă exercițiu") {
                if let setsInt = Int(sets), let repsInt = Int(repetitions), let weightInt = Int(weight) {
                    // Creăm un nou exercițiu cu datele introduse și data selectată
                    let newExercise = GymExercise(name: name, muscleGroup: selectedMuscleGroup, sets: setsInt, repetitions: repsInt, weight: weightInt, date: selectedDate)
                    gymViewModel.addExercise(newExercise, on: selectedDate)  // Pasăm exercițiul și data selectată la ViewModel pentru a fi adăugat
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
        .navigationBarTitle("Adaugă exercițiu", displayMode: .inline)
    }
}
