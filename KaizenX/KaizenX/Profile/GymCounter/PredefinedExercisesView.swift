//
//  PredefinedExercisesView.swift
//  KaizenX
//
//  Created by Cristi Sandu on 27.05.2024.
//

import SwiftUI

struct PredefinedExercisesView: View {
    @Binding var selectedDate: Date
    @ObservedObject var gymViewModel: GymCounterViewModel
    @Environment(\.presentationMode) var presentationMode
    @Binding var selectedPredefinedExercise: PredefinedExercise?
    @State private var exerciseForDetails: PredefinedExercise? = nil
    
    var body: some View {
        NavigationView {
            List {
                ForEach(gymViewModel.muscleGroups, id: \.self) { muscleGroup in
                    Section(header: Text(muscleGroup)) {
                        ForEach(gymViewModel.predefinedExercises.filter { $0.muscleGroup == muscleGroup }, id: \.id) { exercise in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(exercise.name)
                                }
                                Spacer()
                                Button(action: {
                                    exerciseForDetails = exercise
                                }) {
                                    Image(systemName: "info.circle")
                                        .foregroundColor(.accentColor)
                                        .font(.title) // Mărim iconița
                                }
                                .buttonStyle(BorderlessButtonStyle()) // Pentru a evita conflictele de stil
                            }
                            .contentShape(Rectangle()) // Pentru a face întreaga celulă clicabilă
                            .onTapGesture {
                                selectedPredefinedExercise = exercise
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                    }
                }
            }
            .navigationBarTitle("Exerciții Predefinite")
            .sheet(item: $exerciseForDetails) { exercise in
                ExerciseDetailView(exercise: exercise)
            }
        }
    }
}
