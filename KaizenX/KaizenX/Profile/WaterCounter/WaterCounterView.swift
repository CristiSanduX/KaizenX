import SwiftUI

private struct WaterTheme {
    let ringColors: [Color]
    let shadowColor: Color
    let icon: String
    let message: String
    let messageColor: Color
    let tip: String

    init(intake: Double, goal: Double) {
        let ratio = intake / goal
        switch ratio {
        case ..<0.25:
            ringColors = [.red.opacity(0.7), .red]; shadowColor = .red.opacity(0.4)
            icon = "drop.slash"; message = "Ai uitat să bei apă. Corpul tău are nevoie."; messageColor = .red
            tip = "Deshidratarea ușoară poate provoca oboseală, dureri de cap și probleme de concentrare."
        case 0.25..<0.5:
            ringColors = [.orange.opacity(0.7), .orange]; shadowColor = .orange.opacity(0.4)
            icon = "drop"; message = "Un bun start. Continuă să te hidratezi."; messageColor = .orange
            tip = "Bea un pahar de apă înainte de fiecare masă — ajută digestia și reduce senzația de foame."
        case 0.5..<0.75:
            ringColors = [.blue.opacity(0.7), .blue]; shadowColor = .blue.opacity(0.4)
            icon = "drop.fill"; message = "Jumătate din drum. Mai ai puțin."; messageColor = .blue
            tip = "Apa ajută la transportul nutrienților și eliminarea toxinelor din organism."
        case 0.75..<1.0:
            ringColors = [.cyan.opacity(0.7), .cyan]; shadowColor = .cyan.opacity(0.4)
            icon = "flame.fill"; message = "Aproape acolo! Un pahar și ești gata."; messageColor = .cyan
            tip = "Hidratarea corectă menține temperatura corpului stabilă și îmbunătățește performanța fizică."
        default:
            ringColors = [.green.opacity(0.7), .green]; shadowColor = .green.opacity(0.4)
            icon = "checkmark.seal.fill"; message = "Obiectiv atins. Corpul tău îți mulțumește!"; messageColor = .green
            tip = "Hidratarea zilnică optimă îmbunătățește concentrarea, energia și recuperarea după antrenament."
        }
    }
}

struct WaterCounterView: View {
    @StateObject private var viewModel = WaterCounterViewModel()
    @State private var showGoalPicker = false

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ro_RO")
        f.dateFormat = "d MMMM yyyy"
        return f
    }()
    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f
    }()

    private var progress: Double { min(viewModel.waterIntake / viewModel.waterGoal, 1.0) }
    private var theme: WaterTheme { WaterTheme(intake: viewModel.waterIntake, goal: viewModel.waterGoal) }

    private func formatGoalLabel(_ ml: Double) -> String {
        let l = ml / 1000
        if l.truncatingRemainder(dividingBy: 1) == 0 { return "\(Int(l)) L" }
        if l.truncatingRemainder(dividingBy: 0.5) == 0 { return String(format: "%.1f L", l) }
        return String(format: "%.2f L", l)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                headerSection
                ringSection
                goalSection
                quickAddSection
                statsSection
                motivationalSection
                tipSection
                historySection
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
        .background(Color(.systemGray6).ignoresSafeArea())
        .sheet(isPresented: $showGoalPicker) {
            GoalPickerSheet(currentGoal: $viewModel.waterGoal)
                .presentationDetents([.fraction(0.45)])
        }
        .onAppear {
            Task {
                try? await viewModel.loadCurrentUser()
                try? await viewModel.loadTodayWaterIntake()
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 4) {
            Text("Hidratarea de astăzi")
                .font(.title2.weight(.semibold))
                .foregroundStyle(.primary)
            Text(Self.dateFormatter.string(from: Date()))
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 8)
    }

    private var ringSection: some View {
        ZStack {
            Circle()
                .stroke(Color(.systemGray4), lineWidth: 24)
                .frame(width: 220, height: 220)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    LinearGradient(colors: theme.ringColors, startPoint: .topLeading, endPoint: .bottomTrailing),
                    style: StrokeStyle(lineWidth: 24, lineCap: .round)
                )
                .frame(width: 220, height: 220)
                .rotationEffect(.degrees(-90))
                .shadow(color: theme.shadowColor, radius: 8, x: 0, y: 4)
                .animation(.easeInOut(duration: 0.6), value: progress)

            VStack(spacing: 4) {
                Text(String(format: "%d", Int(viewModel.waterIntake)))
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                    .contentTransition(.numericText())
                    .animation(.easeInOut(duration: 0.4), value: viewModel.waterIntake)
                Text("din \(String(format: "%d", Int(viewModel.waterGoal))) ml")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var goalSection: some View {
        Button { showGoalPicker = true } label: {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Obiectiv zilnic")
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(.secondary)
                    Text(formatGoalLabel(viewModel.waterGoal))
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.primary)
                }
                Spacer()
                Text("Schimbă")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(theme.messageColor)
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(theme.messageColor)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }

    private var quickAddSection: some View {
        VStack(spacing: 10) {
            Text("Adaugă rapid")
                .font(.footnote.weight(.medium))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 10) {
                ForEach([100, 200, 300, 500], id: \.self) { amount in
                    Button {
                        Task { try? await viewModel.addWaterIntake(amount: Double(amount)) }
                    } label: {
                        Text("+\(amount)ml")
                            .font(.subheadline.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color(.secondarySystemGroupedBackground))
                            .foregroundStyle(theme.messageColor)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(theme.messageColor.opacity(0.3), lineWidth: 1)
                            )
                    }
                }
            }
        }
    }

    private var statsSection: some View {
        HStack(spacing: 12) {
            WaterStatCard(
                title: "Rămase",
                value: "\(max(0, Int(viewModel.waterGoal - viewModel.waterIntake)))",
                unit: "ml",
                color: theme.messageColor
            )
            WaterStatCard(
                title: "Pahare",
                value: "\(Int(viewModel.waterIntake / 250))",
                unit: "din \(Int(viewModel.waterGoal / 250))",
                color: theme.messageColor
            )
            WaterStatCard(
                title: "Progres",
                value: "\(Int(progress * 100))",
                unit: "%",
                color: theme.messageColor
            )
        }
    }

    private var motivationalSection: some View {
        HStack(spacing: 12) {
            Image(systemName: theme.icon)
                .font(.title2)
                .foregroundStyle(theme.messageColor)
            Text(theme.message)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(theme.messageColor)
            Spacer()
        }
        .padding(.horizontal, 4)
    }

    private var tipSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Sfatul zilei", systemImage: "lightbulb.fill")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(theme.tip)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    @ViewBuilder
    private var historySection: some View {
        if !viewModel.waterEntries.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                Text("Istoric de azi")
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(.secondary)

                ForEach(viewModel.waterEntries.sorted { $0.timestamp > $1.timestamp }) { entry in
                    HStack(spacing: 12) {
                        Image(systemName: "drop.fill")
                            .font(.caption)
                            .foregroundStyle(.blue.opacity(0.7))
                        Text("+\(Int(entry.amount)) ml")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.primary)
                        Spacer()
                        Text(Self.timeFormatter.string(from: entry.timestamp))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Button {
                            Task { try? await viewModel.deleteWaterEntry(entry) }
                        } label: {
                            Image(systemName: "trash")
                                .font(.caption)
                                .foregroundStyle(.red.opacity(0.7))
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }
}

private struct GoalPickerSheet: View {
    @Binding var currentGoal: Double
    @Environment(\.dismiss) private var dismiss
    @State private var selection: Double

    init(currentGoal: Binding<Double>) {
        self._currentGoal = currentGoal
        self._selection = State(initialValue: currentGoal.wrappedValue)
    }

    var body: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 3)
                .fill(Color(.systemGray4))
                .frame(width: 36, height: 5)
                .padding(.top, 12)

            VStack(spacing: 4) {
                Text("Obiectiv zilnic")
                    .font(.title3.weight(.semibold))
                Text("Câtă apă vrei să bei zilnic?")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 20)
            .padding(.bottom, 4)

            Picker("", selection: $selection) {
                ForEach(WaterCounterViewModel.goalOptions, id: \.self) { option in
                    Text(goalLabel(option)).tag(option)
                }
            }
            .pickerStyle(.wheel)

            Divider()

            Button {
                currentGoal = selection
                dismiss()
            } label: {
                Text("Salvează")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .padding(.bottom, 8)
        }
        .background(Color(.systemGroupedBackground))
    }

    private func goalLabel(_ ml: Double) -> String {
        let l = ml / 1000
        if l.truncatingRemainder(dividingBy: 1) == 0 { return "\(Int(l)) L" }
        if l.truncatingRemainder(dividingBy: 0.5) == 0 { return String(format: "%.1f L", l) }
        return String(format: "%.2f L", l)
    }
}

private struct WaterStatCard: View {
    let title: String
    let value: String
    let unit: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2.weight(.bold))
                .foregroundStyle(color)
                .contentTransition(.numericText())
            Text(unit)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(title)
                .font(.caption2.weight(.medium))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 90)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

#Preview {
    WaterCounterView()
}
