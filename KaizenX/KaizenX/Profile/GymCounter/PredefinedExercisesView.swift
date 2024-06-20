import SwiftUI

struct PredefinedExercisesView: View {
    @Binding var selectedDate: Date
    @ObservedObject var gymViewModel: GymCounterViewModel
    @Environment(\.presentationMode) var presentationMode
    @Binding var selectedPredefinedExercise: PredefinedExercise?
    @State private var exerciseForDetails: PredefinedExercise? = nil

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    ForEach(gymViewModel.muscleGroups, id: \.self) { muscleGroup in
                        NavigationLink(destination: ExerciseListView(
                            muscleGroup: muscleGroup,
                            exercises: gymViewModel.predefinedExercises.filter { $0.muscleGroup == muscleGroup },
                            selectedPredefinedExercise: $selectedPredefinedExercise,
                            exerciseForDetails: $exerciseForDetails)) {
                            MuscleGroupCardView(muscleGroup: muscleGroup)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal)
                    }
                }
            }
            .navigationBarTitle("Exerciții Predefinite", displayMode: .inline)
            .background(Color.white.edgesIgnoringSafeArea(.all))
        }
        // Afișează un view detaliat pentru exercițiul selectat
        .sheet(item: $exerciseForDetails) { exercise in
            ExerciseDetailView(exercise: exercise)
        }
    }
}

// Card pentru afișarea grupei musculare
struct MuscleGroupCardView: View {
    var muscleGroup: String

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(muscleGroup)
                    .font(.title3)
                    .foregroundColor(.black)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.darkRed)
            }
            .padding()
        }
        .background(Color.white)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.darkRed, lineWidth: 2)
        )
        .shadow(radius: 5)
        .padding(.vertical, 5)
    }
}

// View pentru listarea exercițiilor predefinite pentru o anumită grupă musculară
struct ExerciseListView: View {
    var muscleGroup: String
    var exercises: [PredefinedExercise]
    @Binding var selectedPredefinedExercise: PredefinedExercise?
    @Binding var exerciseForDetails: PredefinedExercise?
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var body: some View {
        List {
            ForEach(exercises, id: \.id) { exercise in
                HStack {
                    VStack(alignment: .leading) {
                        Text(exercise.name)
                            .foregroundColor(.black)
                    }
                    Spacer()
                    Button(action: {
                        // Afișează detaliile exercițiului selectat
                        exerciseForDetails = exercise
                    }) {
                        Image(systemName: "info.circle")
                            .foregroundColor(Color.darkRed)
                            .font(.title)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    // Selectează exercițiul predefinit și închide view-ul
                    selectedPredefinedExercise = exercise
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
        .navigationBarTitle(muscleGroup)
        .background(Color.white.edgesIgnoringSafeArea(.all))
    }
}
