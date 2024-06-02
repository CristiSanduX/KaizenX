//
//  ExerciseDetailView.swift
//  KaizenX
//
//  Created by Cristi Sandu on 02.06.2024.
//

import SwiftUI

struct ExerciseDetailView: View {
    var exercise: PredefinedExercise
    
    var body: some View {
        VStack {
            Text(exercise.name)
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
            if let gifURL = Bundle.main.url(forResource: exercise.gifName, withExtension: "gif"),
               let imageData = try? Data(contentsOf: gifURL),
               let gifImage = UIImage.gif(data: imageData) {
                Image(uiImage: gifImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .padding()
            } else {
                Text("Nu s-a putut încărca GIF-ul")
                    .foregroundColor(.red)
                    .padding()
            }
            
            Text(exercise.description)
                .font(.body)
                .padding()
            
            Spacer()
            
            Button(action: {
                // Dismiss the view
            }) {
                Text("Închide")
                    .font(.headline)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.accentColor)
                    .cornerRadius(8)
            }
            .padding(.bottom, 20)
        }
        .padding()
    }
}
