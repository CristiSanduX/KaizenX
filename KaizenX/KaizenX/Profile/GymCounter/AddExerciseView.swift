import SwiftUI

struct AddExerciseView: View {
    @State private var name: String = ""
    @State private var sets: String = ""
    @State private var repetitions: String = ""
    @State private var weight: String = ""
    @Environment(\.presentationMode) var presentationMode
    var gymViewModel: GymCounterViewModel  // Aici este variabila pasată din GymCounterView
    @Binding var selectedMuscleGroup: String
    
    
    var body: some View {
        Form {
            TextField("Nume exercițiu", text: $name)
            
            Picker("Grupă musculară", selection: $selectedMuscleGroup) {
                ForEach(gymViewModel.muscleGroups, id: \.self) { group in
                    Text(group).tag(group)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .pickerStyle(MenuPickerStyle())
            TextField("Număr de serii", text: $sets)
            TextField("Număr de repetări", text: $repetitions)
            TextField("Greutate", text: $weight)
            
            Button("Adaugă exercițiu") {
                let newExercise = GymExercise(name: name, muscleGroup: selectedMuscleGroup, sets: Int(sets) ?? 0, repetitions: Int(repetitions) ?? 0, weight: Double(weight) ?? 0.0, date: Date())
                gymViewModel.addExercise(newExercise)
                presentationMode.wrappedValue.dismiss()
            }
        }
        .navigationBarTitle("Adaugă exercițiu", displayMode: .inline)
    }
}
