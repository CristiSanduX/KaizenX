//
//  ExerciseDetailView.swift
//  KaizenX
//
//  Created by Cristi Sandu on 02.06.2024.
//

import SwiftUI

struct ExerciseDetailView: View {
    var exercise: PredefinedExercise
    @Environment(\.presentationMode) var presentationMode

    @State private var showContent = false

    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                Text(exercise.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .scaleEffect(showContent ? 1.0 : 0.5)
                    .opacity(showContent ? 1.0 : 0.0)
                    .animation(.easeInOut(duration: 0.6))
                

                if let url = URL(string: exercise.gifName) {
                    GIFImageView(url: url)
                        .frame(width: 300, height: 350)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .aspectRatio(contentMode: .fit)
                        .scaleEffect(showContent ? 1.0 : 0.5)
                        .opacity(showContent ? 1.0 : 0.0)
                        .animation(.easeInOut(duration: 0.6).delay(0.2))
                } else {
                    Text("Nu s-a putut încărca GIF-ul")
                        .foregroundColor(.red)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .scaleEffect(showContent ? 1.0 : 0.5)
                        .opacity(showContent ? 1.0 : 0.0)
                        .animation(.easeInOut(duration: 0.6).delay(0.2))
                }

                Text(exercise.description)
                    .font(.body)
                    .foregroundColor(.black)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .scaleEffect(showContent ? 1.0 : 0.5)
                    .opacity(showContent ? 1.0 : 0.0)
                    .animation(.easeInOut(duration: 0.6).delay(0.4))

                Spacer()

                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Închide")
                        .font(.headline)
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.darkRed)
                        .cornerRadius(8)
                        .shadow(radius: 5)
                        .scaleEffect(showContent ? 1.0 : 0.5)
                        .opacity(showContent ? 1.0 : 0.0)
                        .animation(.easeInOut(duration: 0.6).delay(0.6))
                }
                .padding(.bottom, 20)
            }
            .padding()
        }
        .onAppear {
            withAnimation {
                self.showContent = true
            }
        }
    }
}

struct ExerciseDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseDetailView(exercise: PredefinedExercise(name: "Hammer Curls", muscleGroup: "Biceps", description: "Execută exercițiul stând în picioare sau așezat, ținând câte o ganteră în fiecare mână cu o prindere neutră (palmele orientate una către cealaltă). Flexează brațele la cot, aducând ganterele spre umeri, apoi revino încet la poziția inițială.", gifName: "https://firebasestorage.googleapis.com/v0/b/kaizenx25.appspot.com/o/gifs%2Fincline_bench_press.gif?alt=media&token=f5f9e6aa-c139-4ff1-9d5f-069d9be8b008"))
    }
}
