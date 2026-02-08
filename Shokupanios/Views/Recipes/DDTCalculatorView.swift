import SwiftUI

struct DDTCalculatorView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("useMetricUnits") private var useMetricUnits = true
    @AppStorage("defaultDDT") private var defaultDDT = 78.0
    @AppStorage("defaultDDTMetric") private var defaultDDTMetric = 25.5
    @AppStorage("defaultFrictionFactor") private var defaultFrictionFactor = 22.0
    @AppStorage("defaultFrictionFactorMetric") private var defaultFrictionFactorMetric = 12.0
    @AppStorage("mixingMethod") private var mixingMethod = MixingMethod.standMixer.rawValue

    var hasPreferment: Bool = false

    @State private var desiredDoughTemp = ""
    @State private var roomTemp = ""
    @State private var flourTemp = ""
    @State private var frictionFactor = ""
    @State private var usePreferment = false
    @State private var prefermentTemp = ""
    @State private var showInfo = false

    private var unitLabel: String {
        useMetricUnits ? "°C" : "°F"
    }

    // MARK: - DDT Calculation

    /// Water Temp = (Factor × DDT) - Room Temp - Flour Temp - Friction Factor [- Preferment Temp]
    /// Factor = 3 (straight dough), 4 (with preferment)
    private var calculatedWaterTemp: Double? {
        guard let ddt = Double(desiredDoughTemp),
              let room = Double(roomTemp),
              let flour = Double(flourTemp),
              let friction = Double(frictionFactor) else {
            return nil
        }

        if usePreferment {
            guard let preferment = Double(prefermentTemp) else { return nil }
            return (4.0 * ddt) - room - flour - friction - preferment
        } else {
            return (3.0 * ddt) - room - flour - friction
        }
    }

    private var waterTempWarning: String? {
        guard let temp = calculatedWaterTemp else { return nil }

        if useMetricUnits {
            if temp < 4 { return "Very cold — you may need ice water" }
            if temp > 43 { return "Too hot — could kill yeast" }
        } else {
            if temp < 40 { return "Very cold — you may need ice water" }
            if temp > 110 { return "Too hot — could kill yeast" }
        }
        return nil
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.panCream.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: Spacing.lg) {
                        // Result Card (shown when calculated)
                        if let waterTemp = calculatedWaterTemp {
                            resultCard(waterTemp: waterTemp)
                                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                        }

                        // Inputs
                        inputsSection

                        // Preferment toggle
                        prefermentSection

                        // Info
                        if showInfo {
                            infoSection
                        }
                    }
                    .padding(Spacing.md)
                    .animation(.easeOut(duration: 0.25), value: calculatedWaterTemp != nil)
                }
                .scrollIndicators(.hidden)
            }
            .navigationTitle("Water Temperature")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.terracotta)
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        withAnimation { showInfo.toggle() }
                    } label: {
                        Image(systemName: "info.circle")
                            .foregroundColor(.stoneGray)
                    }
                }
            }
            .onAppear {
                prefillDefaults()
            }
        }
        .presentationDetents([.large])
    }

    // MARK: - Result Card

    private func resultCard(waterTemp: Double) -> some View {
        VStack(spacing: Spacing.md) {
            Text("Use water at")
                .font(.bakerySubheadline)
                .foregroundColor(.stoneGray)

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(String(format: "%.1f", waterTemp))
                    .font(.bakeryMono(48))
                    .foregroundColor(.terracotta)

                Text(unitLabel)
                    .font(.bakerySerif(24))
                    .foregroundColor(.terracotta.opacity(0.7))
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Use water at \(String(format: "%.1f", waterTemp)) \(useMetricUnits ? "degrees Celsius" : "degrees Fahrenheit")")

            // Warning
            if let warning = waterTempWarning {
                HStack(spacing: Spacing.sm) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 12))
                    Text(warning)
                        .font(.bakerySubheadline)
                }
                .foregroundColor(.timerPaused)
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: CornerRadius.sm, style: .continuous)
                        .fill(Color.timerPaused.opacity(0.1))
                )
            }

            // Formula breakdown
            VStack(spacing: Spacing.xs) {
                WarmDivider()
                    .padding(.vertical, Spacing.sm)

                let factor = usePreferment ? "4" : "3"
                Text("(\(factor) \u{00D7} \(desiredDoughTemp)) \u{2212} \(roomTemp) \u{2212} \(flourTemp) \u{2212} \(frictionFactor)\(usePreferment && !prefermentTemp.isEmpty ? " \u{2212} \(prefermentTemp)" : "") = \(String(format: "%.1f", waterTemp))")
                    .font(.bakeryMonoCaption)
                    .foregroundColor(.stoneGray)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(Spacing.lg)
        .warmCardElevated()
    }

    // MARK: - Inputs Section

    private var inputsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Temperatures")
                .sectionHeader()

            VStack(spacing: Spacing.sm) {
                tempInputRow(label: "Desired Dough Temp", value: $desiredDoughTemp, hint: "DDT target")
                WarmDivider()
                tempInputRow(label: "Room Temperature", value: $roomTemp, hint: "Ambient")
                WarmDivider()
                tempInputRow(label: "Flour Temperature", value: $flourTemp, hint: "Measure flour")
                WarmDivider()
                tempInputRow(label: "Friction Factor", value: $frictionFactor, hint: currentMixingMethodName)
            }
        }
        .padding(Spacing.lg)
        .warmCard()
    }

    // MARK: - Preferment Section

    private var prefermentSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Toggle(isOn: $usePreferment) {
                HStack(spacing: Spacing.sm) {
                    Image(systemName: "flask")
                        .font(.system(size: 14))
                        .foregroundColor(.terracotta.opacity(0.8))

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Using Preferment")
                            .font(.bakeryBodyMediumDynamic)
                            .foregroundColor(.inkBrown)
                        Text("Sourdough starter, poolish, biga, etc.")
                            .font(.bakeryCaption)
                            .foregroundColor(.stoneGray)
                    }
                }
            }
            .tint(.terracotta)

            if usePreferment {
                tempInputRow(label: "Preferment Temp", value: $prefermentTemp, hint: "Starter/levain")
            }
        }
        .padding(Spacing.lg)
        .warmCard()
    }

    // MARK: - Info Section

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("About DDT")
                .sectionHeader()

            VStack(alignment: .leading, spacing: Spacing.sm) {
                infoItem(
                    title: "What is DDT?",
                    text: "Desired Dough Temperature is the target temperature for your dough after mixing. It directly affects fermentation rate and bread quality."
                )

                infoItem(
                    title: "The Formula",
                    text: "Water Temp = (3 \u{00D7} DDT) \u{2212} Room Temp \u{2212} Flour Temp \u{2212} Friction Factor. Use 4\u{00D7} when including a preferment temperature."
                )

                infoItem(
                    title: "Friction Factor",
                    text: "Heat generated by mixing. By hand: ~7\u{00B0}F (4\u{00B0}C). Stand mixer: ~22\u{00B0}F (12\u{00B0}C). Spiral mixer: ~30\u{00B0}F (17\u{00B0}C)."
                )

                infoItem(
                    title: "Common DDT Ranges",
                    text: "Artisan bread: 75\u{2013}78\u{00B0}F (24\u{2013}26\u{00B0}C). Enriched dough: 76\u{2013}80\u{00B0}F (24\u{2013}27\u{00B0}C). Quick breads: 80\u{2013}85\u{00B0}F (27\u{2013}29\u{00B0}C)."
                )
            }
        }
        .padding(Spacing.lg)
        .warmCard()
    }

    // MARK: - Helper Views

    private func tempInputRow(label: String, value: Binding<String>, hint: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.bakeryBodyDynamic)
                    .foregroundColor(.inkBrown)
                Text(hint)
                    .font(.bakeryCaption)
                    .foregroundColor(.stoneGray)
            }

            Spacer()

            HStack(spacing: Spacing.sm) {
                TextField("--", text: value)
                    .font(.bakeryMono(18))
                    .foregroundColor(.inkBrown)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 60)
                    .padding(.horizontal, Spacing.sm)
                    .padding(.vertical, Spacing.xs)
                    .background(
                        RoundedRectangle(cornerRadius: CornerRadius.sm, style: .continuous)
                            .fill(Color.panCrumb.opacity(0.5))
                    )

                Text(unitLabel)
                    .font(.bakerySubheadline)
                    .foregroundColor(.stoneGray)
                    .frame(width: 24)
            }
        }
    }

    private func infoItem(title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(title)
                .font(.bakerySubheadlineMedium)
                .foregroundColor(.inkBrown)
            Text(text)
                .font(.bakerySubheadline)
                .foregroundColor(.stoneGray)
                .lineSpacing(2)
        }
        .padding(.vertical, Spacing.xs)
    }

    // MARK: - Helpers

    private var currentMixingMethodName: String {
        (MixingMethod(rawValue: mixingMethod) ?? .standMixer).displayName
    }

    private func prefillDefaults() {
        if useMetricUnits {
            desiredDoughTemp = formatNumber(defaultDDTMetric)
            frictionFactor = formatNumber(defaultFrictionFactorMetric)
        } else {
            desiredDoughTemp = formatNumber(defaultDDT)
            frictionFactor = formatNumber(defaultFrictionFactor)
        }
        usePreferment = hasPreferment
    }

    private func formatNumber(_ value: Double) -> String {
        if value == value.rounded() {
            return "\(Int(value))"
        } else {
            return String(format: "%.1f", value)
        }
    }
}

#Preview {
    DDTCalculatorView(hasPreferment: false)
}
