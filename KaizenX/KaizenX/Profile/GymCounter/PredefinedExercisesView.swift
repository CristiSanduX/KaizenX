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
    
    var body: some View {
        NavigationView {
            List {
                ForEach(gymViewModel.muscleGroups, id: \.self) { muscleGroup in
                    Section(header: Text(muscleGroup)) {
                        ForEach(gymViewModel.predefinedExercises.filter { $0.muscleGroup == muscleGroup }, id: \.name) { exercise in
                            Button(action: {
                                let newExercise = GymExercise(name: exercise.name, muscleGroup: exercise.muscleGroup, sets: 0, repetitions: 0, weight: 0, date: selectedDate)
                                gymViewModel.addExercise(newExercise, on: selectedDate)
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                HStack {
                                    Text(exercise.name)
                                    Spacer()
                                    Image(exercise.imageName)
                                        .resizable()
                                        .frame(width: 50, height: 50)
                                }
                            }
                        }
                    }
                }
            }
            .navigationBarTitle("Exerciții Predefinite")
        }
    }
}
