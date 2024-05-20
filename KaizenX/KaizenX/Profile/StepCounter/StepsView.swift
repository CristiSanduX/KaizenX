import SwiftUI

struct StepsView: View {
    @StateObject private var viewModel = ProfileViewModel()
    
    var body: some View {
        VStack {
            Text("Activitatea de Astăzi")
                .font(.title)
                .padding()
            
            AnimationNumber()
                .padding()
                .background(RoundedRectangle(cornerRadius: 20).fill(Color(.systemGray6)))
                .shadow(radius: 5)
                .padding()
            
            VStack(alignment: .leading) {
                Text("Progresul Zilnic")
                    .font(.headline)
                    .padding(.bottom, 10)
                
                ProgressView(value: viewModel.steps / 10000) 
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    .padding(.bottom, 20)
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("Pași")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("\(Int(viewModel.steps))")
                            .font(.title3)
                    }
                    Spacer()
                    VStack(alignment: .leading) {
                        Text("Obiectiv")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("10.000")
                            .font(.title3)
                    }
                }
                .padding(.bottom, 20)
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("Distanță")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text(String(format: "%.2f km", viewModel.steps * 0.0008)) // Aproximativ 0.0008 km per pas
                            .font(.title3)
                    }
                    Spacer()
                    VStack(alignment: .leading) {
                        Text("Calorii Arse")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text(String(format: "%.0f kcal", viewModel.steps * 0.04)) // Aproximativ 0.04 kcal per pas
                            .font(.title3)
                    }
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 20).fill(Color(.systemGray6)))
            .shadow(radius: 5)
            .padding()
            
            Spacer()
        }
        .padding()
        .onAppear {
            viewModel.loadSteps()
        }
    }
}

#Preview {
    StepsView()
}
