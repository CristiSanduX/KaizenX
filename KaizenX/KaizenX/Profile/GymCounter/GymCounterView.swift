//
//  GymCounterView.swift
//  KaizenX
//
//  Created by Cristi Sandu on 23.12.2023.
//

import SwiftUI
import HealthKit
import PDFKit
import UIKit

// Extinderea pentru a adăuga denumiri de activități la tipurile de antrenamente din HealthKit
extension HKWorkoutActivityType {
    var activityName: String {
        switch self {
        case .traditionalStrengthTraining:
            return "Antrenament de Forță"
        case .running:
            return "Alergare"
        case .cycling:
            return "Ciclism"
        case .swimming:
            return "Înot"
        case .walking:
            return "Mers"
        default:
            return "Altele"
        }
    }
}

// Structura principală pentru view-ul de contorizare a antrenamentelor
struct GymCounterView: View {
    @StateObject var viewModel = GymCounterViewModel()
    @State private var showingAddExerciseView = false
    @State private var showingPredefinedExerciseView = false
    @State private var showingExercisesPopup = false
    @State private var showingWorkoutsPopup = false
    @State private var selectedDate = Date()
    @State private var selectedPredefinedExercise: PredefinedExercise? = nil
    
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
                
                Spacer()
                HStack {
                    Button(action: {
                        showingPredefinedExerciseView = true
                    }) {
                        HStack {
                            Image(systemName: "list.bullet")
                                .font(.headline)
                            Text("Alege exercițiu predefinit")
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
                        PredefinedExercisesView(
                            selectedDate: $selectedDate,
                            gymViewModel: viewModel,
                            selectedPredefinedExercise: $selectedPredefinedExercise
                        )
                    }
                    
                    Button(action: {
                        showingAddExerciseView = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .font(.headline)
                            Text("Adaugă exercițiu")
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
                        AddExerciseView(
                            selectedMuscleGroup: $viewModel.selectedMuscleGroup,
                            selectedDate: $selectedDate,
                            gymViewModel: viewModel,
                            predefinedExercise: .constant(nil)
                        )
                    }
                }
                .background(Color(.systemGray6).edgesIgnoringSafeArea(.all))
                
                HStack {
                    Button(action: {
                        showingExercisesPopup = true
                    }) {
                        HStack {
                            Image(systemName: "dumbbell.fill")
                                .font(.headline)
                            Text("Antrenamentul la sală")
                                .font(.subheadline)
                                .fontWeight(.bold)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(8)
                    }
                    .sheet(isPresented: $showingExercisesPopup) {
                        ExercisesPopupView(viewModel: viewModel, selectedDate: $selectedDate)
                    }
                    
                    Button(action: {
                        showingWorkoutsPopup = true
                    }) {
                        HStack {
                            Image(systemName: "applewatch")
                                .font(.headline)
                            Text("Antrenamente Apple")
                                .font(.subheadline)
                                .fontWeight(.bold)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .foregroundColor(.white)
                        .background(Color.green)
                        .cornerRadius(8)
                    }
                    .sheet(isPresented: $showingWorkoutsPopup) {
                        WorkoutsPopupView(viewModel: viewModel)
                    }
                }
                .padding(.top, 20)
                
                Button(action: {
                    exportData()
                }) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                            .font(.headline)
                        Text("Exportă antrenament")
                            .font(.subheadline)
                            .fontWeight(.bold)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .foregroundColor(.white)
                    .background(Color.orange)
                    .cornerRadius(8)
                }
                .padding(.top, 10)
                
                Spacer()
            }
            .onChange(of: selectedDate) { oldDate, newDate in
                viewModel.fetchExercisesForDate(newDate)
                viewModel.fetchWorkoutsForDate(newDate)
            }
            .onAppear {
                viewModel.requestAuthorization()
                viewModel.fetchExercisesForDate(selectedDate)
                viewModel.fetchWorkoutsForDate(selectedDate)
            }
        }
        .sheet(item: $selectedPredefinedExercise) { exercise in
            AddExerciseView(
                selectedMuscleGroup: $viewModel.selectedMuscleGroup,
                selectedDate: $selectedDate,
                gymViewModel: viewModel,
                predefinedExercise: .constant(exercise)
            )
        }
    }
    
    // Funcție pentru exportarea datelor în format PDF
    private func exportData() {
        let pdfDocument = PDFDocument()
        let pageBounds = CGRect(x: 0, y: 0, width: 8.5 * 72.0, height: 11 * 72.0) // Dimensiunea paginii
        
        let renderer = UIGraphicsImageRenderer(bounds: pageBounds)
        let img = renderer.image { ctx in
            // Desenează fundalul
            UIColor.white.setFill()
            ctx.fill(pageBounds)
            
            // Desenează textul
            let title = "Antrenament - \(selectedDate.formatted(date: .numeric, time: .omitted))\n\n"
            title.draw(at: CGPoint(x: 20, y: 20), withAttributes: [.font: UIFont.boldSystemFont(ofSize: 20)])
            
            var currentY: CGFloat = 60
            
            if !viewModel.exercises.isEmpty {
                let exerciseTitle = "Exerciții Sala:\n"
                exerciseTitle.draw(at: CGPoint(x: 20, y: currentY), withAttributes: [.font: UIFont.boldSystemFont(ofSize: 16)])
                currentY += 20
                
                for exercise in viewModel.exercises {
                    let exerciseDetail = "\(exercise.name) - \(exercise.muscleGroup)\nSeturi: \(exercise.sets), Repetări: \(exercise.repetitions), Greutate: \(exercise.weight) kg\n\n"
                    exerciseDetail.draw(at: CGPoint(x: 20, y: currentY), withAttributes: [.font: UIFont.systemFont(ofSize: 12)])
                    currentY += 40
                }
            }
            
            if !viewModel.workoutsForSelectedDate.isEmpty {
                let workoutTitle = "Antrenamente Apple Watch:\n"
                workoutTitle.draw(at: CGPoint(x: 20, y: currentY), withAttributes: [.font: UIFont.boldSystemFont(ofSize: 16)])
                currentY += 20
                
                for workout in viewModel.workoutsForSelectedDate {
                    let workoutDetail = "\(workout.workoutActivityType.activityName)\nDurata: \(Int(workout.duration / 60)) min, Calorii: \(Int(workout.totalEnergyBurned?.doubleValue(for: .kilocalorie()) ?? 0)) kcal\n\n"
                    workoutDetail.draw(at: CGPoint(x: 20, y: currentY), withAttributes: [.font: UIFont.systemFont(ofSize: 12)])
                    currentY += 40
                }
            }
        }
        
        let pdfPage = PDFPage(image: img)
        if let pdfPage = pdfPage {
            pdfDocument.insert(pdfPage, at: 0)
        }
        
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("Antrenament_\(selectedDate.formatted(date: .numeric, time: .omitted)).pdf")
        pdfDocument.write(to: url)
        
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true, completion: nil)
        }
    }
    
    // View pentru afișarea exercițiilor într-un pop-up
    struct ExercisesPopupView: View {
        @ObservedObject var viewModel: GymCounterViewModel
        @Binding var selectedDate: Date
        
        var body: some View {
            VStack {
                Text("Antrenamentul la sală")
                    .font(.headline)
                    .foregroundColor(.accentColor)
                    .padding()
                
                if viewModel.exercises.isEmpty {
                    Text("Nu există exerciții pentru data selectată.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ScrollView {
                        ForEach(viewModel.exercises, id: \.id) { exercise in
                            GymExerciseCard(exercise: exercise, viewModel: viewModel, date: selectedDate)
                                .padding(.horizontal)
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    // View pentru afișarea antrenamentelor într-un pop-up
    struct WorkoutsPopupView: View {
        @ObservedObject var viewModel: GymCounterViewModel
        var body: some View {
            VStack {
                Text("Antrenamente Apple Watch")
                    .font(.headline)
                    .foregroundColor(.accentColor)
                    .padding()
                
                if viewModel.workoutsForSelectedDate.isEmpty {
                    Text("Nu există antrenamente pentru data selectată.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ScrollView {
                        ForEach(viewModel.workoutsForSelectedDate, id: \.uuid) { workout in
                            WorkoutCard(workout: workout)
                                .padding(.horizontal)
                        }
                    }
                }
            }
            .padding()
        }
    }
    struct GymExerciseCard: View {
        var exercise: GymExercise
        var viewModel: GymCounterViewModel
        var date: Date
        var body: some View {
            VStack(alignment: .leading) {
                Text(exercise.name)
                    .font(.body)
                    .foregroundColor(.primary)
                Text(exercise.muscleGroup)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("\(exercise.sets) seturi, \(exercise.repetitions) repetări, \(exercise.weight) kg")
                    .font(.body)
                    .foregroundColor(.secondary)
                HStack {
                    Button(action: {
                        viewModel.deleteExercise(exercise, on: date)
                    }) {
                        Text("Delete")
                            .foregroundColor(.red)
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
    }
    
    // View pentru cardul antrenamentelor
    struct WorkoutCard: View {
        var workout: HKWorkout
        var body: some View {
            VStack(alignment: .leading) {
                Text(workout.workoutActivityType.activityName)
                    .font(.body)
                    .foregroundColor(.primary)
                Text("Durata: \(Int(workout.duration / 60)) min")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("\(Int(workout.totalEnergyBurned?.doubleValue(for: .kilocalorie()) ?? 0)) kcal")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
    }
}

