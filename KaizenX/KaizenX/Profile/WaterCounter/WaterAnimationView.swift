import SwiftUI

struct WaterAnimationView: View {
    var waterIntakeGoal: Double
    @Binding var waterIntake: Double

    // Calculul progresului de hidratare ca o valoare între 0 și 1.
    var progress: CGFloat {
        CGFloat(waterIntake / waterIntakeGoal)
    }
    @State private var startAnimation: CGFloat = 0

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            
            ZStack {
                // Imaginea de fundal în forma unui strop de apă.
                Image(systemName: "drop.fill")
                    .resizable()
                    .renderingMode(.template)
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.gray)
                    .scaleEffect(x: 1.1, y: 1)
                    .offset(y: -1)
                
                // Animația de valuri care reprezintă nivelul de apă consumată.
                WaterWave(progress: progress, waveHeight: 0.1, offset: startAnimation)
                    .fill(Color.blue)
                    .overlay(content: {
                        // Stropi de apă pentru un aspect decorativ.
                        Circle().fill(Color.blue.opacity(0.1)).frame(width: 15, height: 15).offset(x: -20)
                        Circle().fill(Color.blue.opacity(0.1)).frame(width: 15, height: 15).offset(x: 40, y: 30)
                        // ... (alte cercuri pentru a completa efectul de stropi)
                    })
                    .mask {
                        Image(systemName: "drop.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(3)
                    }
                    .overlay(alignment: .bottom) {
                        // Butonul plus pentru adăugarea apei.
                        Button(action: {
                            // Acțiune pentru buton (deschiderea unei ferestre pentru a adăuga apă)
                        }, label: {
                            Image(systemName: "plus")
                                .font(.system(size: 25, weight: .black))
                                .foregroundColor(.blue)
                                .shadow(radius: 2)
                                .padding(15)
                                .background(Color.white, in: Circle())
                        })
                        .offset(y: 40)
                    }
            }
            .frame(width: size.width, height: size.height, alignment: .center)
            .onAppear {
                withAnimation(.linear(duration: 5).repeatForever(autoreverses: false)) {
                    startAnimation = size.width * 2
                }
            }
        }
        .frame(height: 350)
    }
}

struct WaterWave: Shape {
    // Proprietățile pentru animația valurilor.
    var progress: CGFloat
    var waveHeight: CGFloat
    var offset: CGFloat
    
    var animatableData: CGFloat {
        get { offset }
        set { offset = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let progressHeight: CGFloat = (1 - progress) * rect.height
        let height = waveHeight * rect.height
        let length = rect.width

        path.move(to: .zero)

        for value in stride(from: 0, through: length, by: 1) {
            let x: CGFloat = value
            let sine: CGFloat = sin(Angle(degrees: value + offset).radians)
            let y: CGFloat = progressHeight + (height * sine)
            path.addLine(to: CGPoint(x: x, y: y))
        }

        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.closeSubpath()

        return path
    }
}
