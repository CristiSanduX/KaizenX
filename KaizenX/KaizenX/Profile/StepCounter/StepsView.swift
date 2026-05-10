import SwiftUI

// MARK: - Step Theme

private struct StepTheme {
    let ringColors: [Color]
    let shadowColor: Color
    let icon: String
    let message: String
    let messageColor: Color
    let tip: String

    init(steps: Double) {
        switch steps {
        case ..<2000:
            ringColors    = [.red.opacity(0.7), .red]
            shadowColor   = .red.opacity(0.4)
            icon          = "figure.stand"
            message       = "Zi activă? Acum e momentul."
            messageColor  = .red
            tip           = "O plimbare de 30 de minute adaugă aproximativ 3.000 de pași. Ieși și tu puțin afară."
        case 2000..<5000:
            ringColors    = [.orange.opacity(0.7), .orange]
            shadowColor   = .orange.opacity(0.4)
            icon          = "figure.walk"
            message       = "Bun start. Continuă ritmul."
            messageColor  = .orange
            tip           = "Mersul pe jos reduce stresul, îmbunătățește somnul și arde calorii fără efort."
        case 5000..<8000:
            ringColors    = [.blue.opacity(0.7), .blue]
            shadowColor   = .blue.opacity(0.4)
            icon          = "figure.walk"
            message       = "Mai mult de jumătate. Nu te opri."
            messageColor  = .blue
            tip           = "Evită liftul și alege scările — fiecare pas contează."
        case 8000..<10000:
            ringColors    = [.purple.opacity(0.7), .purple]
            shadowColor   = .purple.opacity(0.4)
            icon          = "flame.fill"
            message       = "Aproape! Câțiva pași și gata."
            messageColor  = .purple
            tip           = "Ești la un pas de obiectiv. Dă o tură scurtă și bifează-l."
        default:
            ringColors    = [.green.opacity(0.7), .green]
            shadowColor   = .green.opacity(0.4)
            icon          = "checkmark.seal.fill"
            message       = "Obiectiv atins. Felicitări!"
            messageColor  = .green
            tip           = "10.000 de pași pe zi scad riscul de boli cardiovasculare cu până la 30%."
        }
    }
}

// MARK: - Steps View

struct StepsView: View {
    @StateObject private var viewModel = ProfileViewModel()

    private let goal: Double = 10000

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ro_RO")
        f.dateFormat = "d MMMM yyyy"
        return f
    }()

    private var progress: Double { min(viewModel.steps / goal, 1.0) }
    private var theme: StepTheme { StepTheme(steps: viewModel.steps) }

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {

                // MARK: Header
                VStack(spacing: 4) {
                    Text("Activitatea de astăzi")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                    Text(Self.dateFormatter.string(from: Date()))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 8)

                // MARK: Ring
                ZStack {
                    Circle()
                        .stroke(Color(.systemGray5), lineWidth: 24)
                        .frame(width: 270, height: 270)

                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            LinearGradient(colors: theme.ringColors, startPoint: .topLeading, endPoint: .bottomTrailing),
                            style: StrokeStyle(lineWidth: 24, lineCap: .round)
                        )
                        .frame(width: 270, height: 270)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 1.2), value: viewModel.steps)
                        .shadow(color: theme.shadowColor, radius: 8, x: 0, y: 4)

                    VStack(spacing: 6) {
                        Image(systemName: "figure.walk")
                            .font(.system(size: 30, weight: .semibold))
                            .foregroundStyle(
                                LinearGradient(colors: theme.ringColors, startPoint: .top, endPoint: .bottom)
                            )
                        Text("\(Int(viewModel.steps))")
                            .font(.system(size: 54, weight: .bold, design: .rounded))
                            .contentTransition(.numericText())
                            .animation(.easeInOut(duration: 0.8), value: viewModel.steps)
                        Text("din \(Int(goal)) pași")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                // MARK: Motivational line
                HStack(spacing: 8) {
                    Image(systemName: theme.icon)
                    Text(theme.message)
                        .fontWeight(.medium)
                }
                .font(.subheadline)
                .foregroundStyle(theme.messageColor)

                // MARK: Stats
                HStack(spacing: 12) {
                    StepStatCard(icon: "ruler", iconColor: .blue,
                                 value: String(format: "%.2f", viewModel.steps * 0.0008), unit: "km", label: "Distanță")
                    StepStatCard(icon: "flame.fill", iconColor: .orange,
                                 value: "\(Int(viewModel.steps * 0.04))", unit: "kcal", label: "Calorii")
                    StepStatCard(icon: "target", iconColor: theme.messageColor,
                                 value: "\(Int(progress * 100))", unit: "%", label: "Progres")
                }
                .frame(height: 110)
                .padding(.horizontal, 20)

                // MARK: Tip
                VStack(alignment: .leading, spacing: 8) {
                    Label("Sfatul zilei", systemImage: "lightbulb.fill")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.orange)
                    Text(theme.tip)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            }
        }
        .onAppear { viewModel.loadSteps() }
    }
}

// MARK: - Stat Card

private struct StepStatCard: View {
    let icon: String
    let iconColor: Color
    let value: String
    let unit: String
    let label: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(iconColor)
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(value)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                Text(unit)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    StepsView()
}
