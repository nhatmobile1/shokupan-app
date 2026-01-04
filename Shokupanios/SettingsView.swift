import SwiftUI

struct SettingsView: View {
    // User preferences stored in UserDefaults
    @AppStorage("useMetricUnits") private var useMetricUnits = true
    @AppStorage("appTheme") private var appTheme = AppTheme.system.rawValue
    @AppStorage("panSize1Kin") private var panSize1Kin = 250.0
    @AppStorage("panSize1_5Kin") private var panSize1_5Kin = 375.0
    @AppStorage("panSize2Kin") private var panSize2Kin = 500.0

    var body: some View {
        NavigationStack {
            ZStack {
                WarmGradientBackground()

                ScrollView {
                    VStack(spacing: Spacing.lg) {
                        // Units Section
                        settingsCard {
                            VStack(alignment: .leading, spacing: Spacing.md) {
                                Label {
                                    Text("Units")
                                        .sectionHeader()
                                } icon: {
                                    Image(systemName: "scalemass")
                                        .font(.system(size: 12))
                                        .foregroundColor(.crustBrown)
                                }

                                Picker("Weight Units", selection: $useMetricUnits) {
                                    Text("Metric (grams)").tag(true)
                                    Text("Imperial (ounces)").tag(false)
                                }
                                .pickerStyle(.segmented)
                            }
                        }

                        // Appearance Section
                        settingsCard {
                            VStack(alignment: .leading, spacing: Spacing.md) {
                                Label {
                                    Text("Appearance")
                                        .sectionHeader()
                                } icon: {
                                    Image(systemName: "paintbrush")
                                        .font(.system(size: 12))
                                        .foregroundColor(.crustBrown)
                                }

                                HStack(spacing: Spacing.sm) {
                                    ForEach(AppTheme.allCases, id: \.self) { theme in
                                        Button {
                                            withAnimation(.easeOut(duration: 0.2)) {
                                                appTheme = theme.rawValue
                                            }
                                        } label: {
                                            VStack(spacing: Spacing.sm) {
                                                ZStack {
                                                    RoundedRectangle(cornerRadius: CornerRadius.md, style: .continuous)
                                                        .fill(theme.previewColor)
                                                        .frame(height: 44)
                                                        .overlay(
                                                            RoundedRectangle(cornerRadius: CornerRadius.md, style: .continuous)
                                                                .stroke(appTheme == theme.rawValue ? Color.terracotta : Color.panCrumb, lineWidth: appTheme == theme.rawValue ? 2 : 1)
                                                        )

                                                    Image(systemName: theme.icon)
                                                        .font(.system(size: 16))
                                                        .foregroundColor(theme == .dark ? .white : .inkBrown)
                                                }

                                                Text(theme.displayName)
                                                    .font(.bakeryBody(12))
                                                    .foregroundColor(appTheme == theme.rawValue ? .terracotta : .stoneGray)
                                            }
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }

                        // Pan Size Presets Section
                        settingsCard {
                            VStack(alignment: .leading, spacing: Spacing.md) {
                                Label {
                                    Text("Pan Sizes")
                                        .sectionHeader()
                                } icon: {
                                    Image(systemName: "square.resize")
                                        .font(.system(size: 12))
                                        .foregroundColor(.crustBrown)
                                }

                                VStack(spacing: Spacing.sm) {
                                    panSizeRow(label: "1 kin", value: $panSize1Kin)
                                    WarmDivider()
                                    panSizeRow(label: "1.5 kin", value: $panSize1_5Kin)
                                    WarmDivider()
                                    panSizeRow(label: "2 kin", value: $panSize2Kin)
                                }

                                Button {
                                    withAnimation(.easeOut(duration: 0.2)) {
                                        panSize1Kin = 250.0
                                        panSize1_5Kin = 375.0
                                        panSize2Kin = 500.0
                                    }
                                } label: {
                                    HStack {
                                        Image(systemName: "arrow.counterclockwise")
                                            .font(.system(size: 12))
                                        Text("Reset to Defaults")
                                            .font(.bakeryBody(14))
                                    }
                                    .foregroundColor(.terracotta)
                                }
                                .padding(.top, Spacing.sm)

                                Text("Customize flour amounts for your pan sizes. These appear as quick presets when scaling recipes.")
                                    .font(.bakeryBody(12))
                                    .foregroundColor(.stoneGray)
                                    .padding(.top, Spacing.xs)
                            }
                        }

                        // Account Section
                        settingsCard {
                            VStack(alignment: .leading, spacing: Spacing.md) {
                                Label {
                                    Text("Account")
                                        .sectionHeader()
                                } icon: {
                                    Image(systemName: "person")
                                        .font(.system(size: 12))
                                        .foregroundColor(.crustBrown)
                                }

                                NavigationLink {
                                    ProfilePlaceholderView()
                                } label: {
                                    HStack(spacing: Spacing.md) {
                                        ZStack {
                                            Circle()
                                                .fill(Color.panCrumb)
                                                .frame(width: 48, height: 48)

                                            Image(systemName: "person.fill")
                                                .font(.system(size: 18))
                                                .foregroundColor(.crustBrown.opacity(0.6))
                                        }

                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Sign In")
                                                .font(.bakeryBodyMedium(16))
                                                .foregroundColor(.inkBrown)
                                            Text("Sync recipes across devices")
                                                .font(.bakeryBody(13))
                                                .foregroundColor(.stoneGray)
                                        }

                                        Spacer()

                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundColor(.stoneGray.opacity(0.4))
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }

                        // About Section
                        settingsCard {
                            VStack(alignment: .leading, spacing: Spacing.md) {
                                Label {
                                    Text("About")
                                        .sectionHeader()
                                } icon: {
                                    Image(systemName: "info.circle")
                                        .font(.system(size: 12))
                                        .foregroundColor(.crustBrown)
                                }

                                VStack(spacing: 0) {
                                    aboutRow(title: "Version", value: "1.0.0")

                                    WarmDivider()
                                        .padding(.vertical, Spacing.sm)

                                    Link(destination: URL(string: "https://github.com")!) {
                                        aboutLinkRow(title: "Source Code", icon: "arrow.up.right.square")
                                    }

                                    WarmDivider()
                                        .padding(.vertical, Spacing.sm)

                                    Link(destination: URL(string: "mailto:feedback@example.com")!) {
                                        aboutLinkRow(title: "Send Feedback", icon: "envelope")
                                    }
                                }
                            }
                        }

                        // App branding
                        VStack(spacing: Spacing.sm) {
                            Image(systemName: "oven")
                                .font(.system(size: 24, weight: .light))
                                .foregroundColor(.crustBrown.opacity(0.4))

                            Text("Shokupan")
                                .font(.bakerySerif(16))
                                .foregroundColor(.crustBrown.opacity(0.6))

                            Text("Made with care for bakers")
                                .font(.bakeryBody(12))
                                .foregroundColor(.stoneGray.opacity(0.6))
                        }
                        .padding(.vertical, Spacing.xl)
                    }
                    .padding(.horizontal, Spacing.md)
                    .padding(.vertical, Spacing.sm)
                }
                .scrollIndicators(.hidden)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
        .tint(.terracotta)
    }

    // MARK: - Helper Views

    @ViewBuilder
    private func settingsCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(Spacing.lg)
            .warmCard()
    }

    private func panSizeRow(label: String, value: Binding<Double>) -> some View {
        HStack {
            Text(label)
                .font(.bakeryBody(15))
                .foregroundColor(.inkBrown)

            Spacer()

            HStack(spacing: Spacing.sm) {
                TextField("", value: value, format: .number)
                    .font(.bakeryMono(16))
                    .foregroundColor(.inkBrown)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 60)
                    .padding(.horizontal, Spacing.sm)
                    .padding(.vertical, Spacing.xs)
                    .background(
                        RoundedRectangle(cornerRadius: CornerRadius.sm, style: .continuous)
                            .fill(Color.panCrumb.opacity(0.5))
                    )

                Text("g flour")
                    .font(.bakeryBody(13))
                    .foregroundColor(.stoneGray)
            }
        }
    }

    private func aboutRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.bakeryBody(15))
                .foregroundColor(.inkBrown)
            Spacer()
            Text(value)
                .font(.bakeryMono(14))
                .foregroundColor(.stoneGray)
        }
    }

    private func aboutLinkRow(title: String, icon: String) -> some View {
        HStack {
            Text(title)
                .font(.bakeryBody(15))
                .foregroundColor(.inkBrown)
            Spacer()
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(.stoneGray)
        }
    }
}

// MARK: - App Theme

enum AppTheme: String, CaseIterable {
    case system = "system"
    case light = "light"
    case dark = "dark"

    var displayName: String {
        switch self {
        case .system: return "Auto"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }

    var icon: String {
        switch self {
        case .system: return "circle.lefthalf.filled"
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        }
    }

    var previewColor: Color {
        switch self {
        case .system: return Color.panCrumb
        case .light: return Color.flourWhite
        case .dark: return Color.inkBrown
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

// MARK: - Profile Placeholder

struct ProfilePlaceholderView: View {
    var body: some View {
        ZStack {
            WarmGradientBackground()

            VStack(spacing: Spacing.lg) {
                ZStack {
                    Circle()
                        .fill(Color.panCrumb)
                        .frame(width: 100, height: 100)

                    Image(systemName: "person.crop.circle.badge.plus")
                        .font(.system(size: 48, weight: .light))
                        .foregroundColor(.crustBrown.opacity(0.5))
                }

                VStack(spacing: Spacing.sm) {
                    Text("Coming Soon")
                        .font(.bakerySerifMedium(24))
                        .foregroundColor(.inkBrown)

                    Text("Sign in to sync your recipes across all your devices and back them up to the cloud.")
                        .font(.bakeryBody(15))
                        .foregroundColor(.stoneGray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Spacing.xl)
                }
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    SettingsView()
}
