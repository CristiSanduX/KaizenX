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
                // Afișează numele exercițiului
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
                    .animation(.easeInOut(duration: 0.6), value: showContent)

                // Încarcă și afișează GIF-ul exercițiului dacă există
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
                        .animation(.easeInOut(duration: 0.6).delay(0.2), value: showContent)
                } else {
                    Text("Nu s-a putut încărca GIF-ul")
                        .foregroundColor(.red)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .scaleEffect(showContent ? 1.0 : 0.5)
                        .opacity(showContent ? 1.0 : 0.0)
                        .animation(.easeInOut(duration: 0.6).delay(0.2), value: showContent)
                }

                // Afișează descrierea exercițiului
                Text(exercise.description)
                    .font(.body)
                    .foregroundColor(.black)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .scaleEffect(showContent ? 1.0 : 0.5)
                    .opacity(showContent ? 1.0 : 0.0)
                    .animation(.easeInOut(duration: 0.6).delay(0.4), value: showContent)

                Spacer()

                // Buton pentru închiderea view-ului
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
                        .animation(.easeInOut(duration: 0.6).delay(0.6), value: showContent)
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
