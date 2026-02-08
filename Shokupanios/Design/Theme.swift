import SwiftUI

// MARK: - Shokupan Design System
// A wabi-sabi inspired theme: warm, minimal, and serene
// Supports Dynamic Type, Dark Mode, and Accessibility

// MARK: - Color Palette (Adaptive for Light/Dark Mode)
extension Color {
    // Primary backgrounds - warm cream tones (light) / dark browns (dark)
    static let panCream = Color("PanCream", bundle: nil, defaultLight: Color(red: 0.98, green: 0.96, blue: 0.92), defaultDark: Color(red: 0.12, green: 0.11, blue: 0.10))
    static let panCrumb = Color("PanCrumb", bundle: nil, defaultLight: Color(red: 0.95, green: 0.92, blue: 0.86), defaultDark: Color(red: 0.18, green: 0.16, blue: 0.14))

    // Accent - terracotta and warm browns
    static let crustBrown = Color("CrustBrown", bundle: nil, defaultLight: Color(red: 0.76, green: 0.60, blue: 0.42), defaultDark: Color(red: 0.82, green: 0.66, blue: 0.48))
    static let terracotta = Color("Terracotta", bundle: nil, defaultLight: Color(red: 0.80, green: 0.52, blue: 0.40), defaultDark: Color(red: 0.88, green: 0.58, blue: 0.46))
    static let warmBrown = Color("WarmBrown", bundle: nil, defaultLight: Color(red: 0.45, green: 0.35, blue: 0.28), defaultDark: Color(red: 0.75, green: 0.68, blue: 0.60))

    // Text colors
    static let inkBrown = Color("InkBrown", bundle: nil, defaultLight: Color(red: 0.25, green: 0.22, blue: 0.20), defaultDark: Color(red: 0.92, green: 0.90, blue: 0.88))
    static let stoneGray = Color("StoneGray", bundle: nil, defaultLight: Color(red: 0.55, green: 0.52, blue: 0.48), defaultDark: Color(red: 0.62, green: 0.60, blue: 0.56))

    // Supporting colors
    static let flourWhite = Color("FlourWhite", bundle: nil, defaultLight: Color(red: 1.0, green: 0.99, blue: 0.97), defaultDark: Color(red: 0.15, green: 0.14, blue: 0.13))
    static let yeastGold = Color("YeastGold", bundle: nil, defaultLight: Color(red: 0.85, green: 0.72, blue: 0.45), defaultDark: Color(red: 0.90, green: 0.78, blue: 0.50))
    static let steamWhite = Color("SteamWhite", bundle: nil, defaultLight: Color(red: 0.98, green: 0.97, blue: 0.95).opacity(0.9), defaultDark: Color(red: 0.20, green: 0.19, blue: 0.18).opacity(0.9))

    // Semantic colors
    static let yudaneColor = Color("YudaneColor", bundle: nil, defaultLight: Color(red: 0.55, green: 0.68, blue: 0.72), defaultDark: Color(red: 0.62, green: 0.75, blue: 0.78))
    static let prefermentColor = Color("PrefermentColor", bundle: nil, defaultLight: Color(red: 0.72, green: 0.65, blue: 0.55), defaultDark: Color(red: 0.78, green: 0.72, blue: 0.62))
    static let finalDoughColor = Color("FinalDoughColor", bundle: nil, defaultLight: Color(red: 0.80, green: 0.52, blue: 0.40), defaultDark: Color(red: 0.88, green: 0.58, blue: 0.46))

    /// Helper initializer for adaptive colors with fallbacks
    /// Uses asset catalog color if available, otherwise falls back to programmatic colors
    init(_ name: String, bundle: Bundle?, defaultLight: Color, defaultDark: Color) {
        // Try to load from asset catalog first
        if let _ = UIColor(named: name, in: bundle, compatibleWith: nil) {
            self.init(name, bundle: bundle)
        } else {
            // Fallback to programmatic adaptive color
            self.init(uiColor: UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .dark
                    ? UIColor(defaultDark)
                    : UIColor(defaultLight)
            })
        }
    }

    // Semantic timer colors (adaptive for dark mode)
    static let timerRunning = Color("TimerRunning", bundle: nil, defaultLight: Color(red: 0.30, green: 0.70, blue: 0.40), defaultDark: Color(red: 0.40, green: 0.80, blue: 0.50))
    static let timerPaused = Color("TimerPaused", bundle: nil, defaultLight: Color(red: 0.90, green: 0.65, blue: 0.20), defaultDark: Color(red: 0.95, green: 0.72, blue: 0.30))
    static let stepCompleted = Color("StepCompleted", bundle: nil, defaultLight: Color(red: 0.30, green: 0.70, blue: 0.40), defaultDark: Color(red: 0.40, green: 0.80, blue: 0.50))

    // Tag colors - Studio Ghibli inspired palette (dark-mode adaptive)
    static let tagColors: [Color] = [
        Color(uiColor: UIColor { t in t.userInterfaceStyle == .dark
            ? UIColor(red: 0.90, green: 0.45, blue: 0.42, alpha: 1)
            : UIColor(red: 0.80, green: 0.33, blue: 0.30, alpha: 1) }),  // Spirited Away red
        Color(uiColor: UIColor { t in t.userInterfaceStyle == .dark
            ? UIColor(red: 0.30, green: 0.58, blue: 0.70, alpha: 1)
            : UIColor(red: 0.20, green: 0.45, blue: 0.55, alpha: 1) }),  // Spirited Away blue
        Color(uiColor: UIColor { t in t.userInterfaceStyle == .dark
            ? UIColor(red: 0.62, green: 0.78, blue: 0.58, alpha: 1)
            : UIColor(red: 0.56, green: 0.72, blue: 0.52, alpha: 1) }),  // Totoro light green
        Color(uiColor: UIColor { t in t.userInterfaceStyle == .dark
            ? UIColor(red: 0.45, green: 0.65, blue: 0.45, alpha: 1)
            : UIColor(red: 0.35, green: 0.55, blue: 0.35, alpha: 1) }),  // Totoro dark green
        Color(uiColor: UIColor { t in t.userInterfaceStyle == .dark
            ? UIColor(red: 0.50, green: 0.65, blue: 0.80, alpha: 1)
            : UIColor(red: 0.68, green: 0.82, blue: 0.95, alpha: 1) }),  // Howl's sky blue
        Color(uiColor: UIColor { t in t.userInterfaceStyle == .dark
            ? UIColor(red: 0.95, green: 0.58, blue: 0.46, alpha: 1)
            : UIColor(red: 0.90, green: 0.52, blue: 0.40, alpha: 1) }),  // Howl's coral
        Color(uiColor: UIColor { t in t.userInterfaceStyle == .dark
            ? UIColor(red: 0.35, green: 0.52, blue: 0.40, alpha: 1)
            : UIColor(red: 0.22, green: 0.38, blue: 0.28, alpha: 1) }),  // Mononoke forest
        Color(uiColor: UIColor { t in t.userInterfaceStyle == .dark
            ? UIColor(red: 0.65, green: 0.75, blue: 0.58, alpha: 1)
            : UIColor(red: 0.58, green: 0.68, blue: 0.52, alpha: 1) }),  // Mononoke sage
        Color(uiColor: UIColor { t in t.userInterfaceStyle == .dark
            ? UIColor(red: 0.85, green: 0.45, blue: 0.42, alpha: 1)
            : UIColor(red: 0.75, green: 0.35, blue: 0.32, alpha: 1) }),  // Kiki's red
        Color(uiColor: UIColor { t in t.userInterfaceStyle == .dark
            ? UIColor(red: 0.40, green: 0.65, blue: 0.82, alpha: 1)
            : UIColor(red: 0.30, green: 0.55, blue: 0.72, alpha: 1) }),  // Wind Rises blue
        Color(uiColor: UIColor { t in t.userInterfaceStyle == .dark
            ? UIColor(red: 0.92, green: 0.78, blue: 0.60, alpha: 1)
            : UIColor(red: 0.88, green: 0.72, blue: 0.55, alpha: 1) }),  // Wind Rises peach
        Color(uiColor: UIColor { t in t.userInterfaceStyle == .dark
            ? UIColor(red: 0.68, green: 0.75, blue: 0.56, alpha: 1)
            : UIColor(red: 0.60, green: 0.68, blue: 0.50, alpha: 1) }),  // Wind Rises olive
    ]

    /// Returns a consistent color for a given tag string
    static func tagColor(for tag: String) -> Color {
        let hash = abs(tag.lowercased().hashValue)
        return tagColors[hash % tagColors.count]
    }
}

// MARK: - Typography (Dynamic Type Support)
extension Font {
    // Display fonts - for titles and headers
    // Uses semantic text styles for Dynamic Type scaling
    static func bakerySerif(_ size: CGFloat) -> Font {
        .system(size: size, weight: .regular, design: .serif)
    }

    static func bakerySerifMedium(_ size: CGFloat) -> Font {
        .system(size: size, weight: .medium, design: .serif)
    }

    // Body fonts - clean and readable
    static func bakeryBody(_ size: CGFloat) -> Font {
        .system(size: size, weight: .regular, design: .rounded)
    }

    static func bakeryBodyMedium(_ size: CGFloat) -> Font {
        .system(size: size, weight: .medium, design: .rounded)
    }

    // Monospace for measurements
    static func bakeryMono(_ size: CGFloat) -> Font {
        .system(size: size, weight: .regular, design: .monospaced)
    }

    // MARK: - Dynamic Type Variants
    // These variants scale with the user's accessibility text size settings

    /// Large title - scales with .largeTitle
    static var bakeryLargeTitle: Font {
        .system(.largeTitle, design: .serif, weight: .regular)
    }

    /// Title - scales with .title2
    static var bakeryTitle: Font {
        .system(.title2, design: .serif, weight: .medium)
    }

    /// Headline - scales with .headline
    static var bakeryHeadline: Font {
        .system(.headline, design: .rounded, weight: .semibold)
    }

    /// Body text - scales with .body
    static var bakeryBodyDynamic: Font {
        .system(.body, design: .rounded, weight: .regular)
    }

    /// Subheadline - scales with .subheadline
    static var bakerySubheadline: Font {
        .system(.subheadline, design: .rounded, weight: .regular)
    }

    /// Caption - scales with .caption
    static var bakeryCaption: Font {
        .system(.caption, design: .rounded, weight: .regular)
    }

    /// Monospace body - scales with .body
    static var bakeryMonoDynamic: Font {
        .system(.body, design: .monospaced, weight: .regular)
    }

    /// Monospace caption - scales with .caption
    static var bakeryMonoCaption: Font {
        .system(.caption, design: .monospaced, weight: .regular)
    }

    /// Body medium - scales with .body, medium weight
    static var bakeryBodyMediumDynamic: Font {
        .system(.body, design: .rounded, weight: .medium)
    }

    /// Subheadline medium - scales with .subheadline, medium weight
    static var bakerySubheadlineMedium: Font {
        .system(.subheadline, design: .rounded, weight: .medium)
    }

    /// Monospace subheadline - scales with .subheadline
    static var bakeryMonoSubheadline: Font {
        .system(.subheadline, design: .monospaced, weight: .regular)
    }

    /// Title 3 - scales with .title3, serif
    static var bakeryTitle3: Font {
        .system(.title3, design: .serif, weight: .medium)
    }
}

// MARK: - Spacing System
struct Spacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}

// MARK: - Corner Radius
struct CornerRadius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
    static let full: CGFloat = 999
}

// MARK: - Custom View Modifiers

struct WarmCardStyle: ViewModifier {
    var isElevated: Bool = false

    func body(content: Content) -> some View {
        content
            .background(Color.flourWhite)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg, style: .continuous))
            .shadow(
                color: Color.warmBrown.opacity(isElevated ? 0.08 : 0.04),
                radius: isElevated ? 12 : 6,
                x: 0,
                y: isElevated ? 4 : 2
            )
    }
}

struct SoftButtonStyle: ButtonStyle {
    var isAccent: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.bakeryBodyMedium(15))
            .foregroundColor(isAccent ? .flourWhite : .warmBrown)
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.md, style: .continuous)
                    .fill(isAccent ? Color.terracotta : Color.panCrumb)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct TagChipStyle: ViewModifier {
    var isSelected: Bool = false

    func body(content: Content) -> some View {
        content
            .font(.bakeryBody(13))
            .foregroundColor(isSelected ? .flourWhite : .warmBrown)
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .background(
                Capsule()
                    .fill(isSelected ? Color.terracotta : Color.panCrumb)
            )
    }
}

struct SectionHeaderStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.bakerySerif(13))
            .foregroundColor(.stoneGray)
            .textCase(.uppercase)
            .tracking(1.2)
    }
}

// MARK: - View Extensions

extension View {
    func warmCard(elevated: Bool = false) -> some View {
        modifier(WarmCardStyle(isElevated: elevated))
    }

    func tagChip(selected: Bool = false) -> some View {
        modifier(TagChipStyle(isSelected: selected))
    }

    func sectionHeader() -> some View {
        modifier(SectionHeaderStyle())
    }
}

// MARK: - Custom Components

struct WarmCardElevatedStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.flourWhite)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg, style: .continuous))
            .shadow(
                color: Color.terracotta.opacity(0.12),
                radius: 8,
                x: 0,
                y: 4
            )
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.lg, style: .continuous)
                    .stroke(Color.terracotta.opacity(0.2), lineWidth: 1.5)
            )
    }
}

extension View {
    func warmCardElevated() -> some View {
        modifier(WarmCardElevatedStyle())
    }
}

struct WarmDivider: View {
    var body: some View {
        Rectangle()
            .fill(Color.panCrumb)
            .frame(height: 1)
    }
}

struct IngredientBadge: View {
    let percentage: Int
    let weight: String

    var body: some View {
        VStack(alignment: .trailing, spacing: 2) {
            Text("\(percentage)%")
                .font(.bakeryMono(12))
                .foregroundColor(.stoneGray)
            Text(weight)
                .font(.bakeryBodyMedium(15))
                .foregroundColor(.inkBrown)
        }
    }
}

struct HydrationIndicator: View {
    let percentage: Int

    var body: some View {
        HStack(spacing: Spacing.xs) {
            Image(systemName: "drop.fill")
                .font(.system(size: 10))
                .foregroundColor(.terracotta.opacity(0.7))
            Text("\(percentage)%")
                .font(.bakeryMono(11))
                .foregroundColor(.warmBrown)
        }
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, Spacing.xs)
        .background(
            Capsule()
                .fill(Color.terracotta.opacity(0.12))
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Hydration \(percentage) percent")
    }
}

struct FlourWeightBadge: View {
    let weight: String

    var body: some View {
        HStack(spacing: Spacing.xs) {
            Image(systemName: "scalemass")
                .font(.system(size: 10))
                .foregroundColor(.crustBrown.opacity(0.7))
            Text(weight)
                .font(.bakeryMono(11))
                .foregroundColor(.warmBrown)
        }
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, Spacing.xs)
        .background(
            Capsule()
                .fill(Color.crustBrown.opacity(0.12))
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Flour weight \(weight)")
    }
}

struct SectionBadge: View {
    let section: IngredientSection

    var color: Color {
        switch section {
        case .yudane: return .yudaneColor
        case .preferment: return .prefermentColor
        case .finalDough: return .finalDoughColor
        }
    }

    var body: some View {
        Text(section.rawValue)
            .font(.bakeryBody(11))
            .foregroundColor(color)
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, Spacing.xs)
            .background(
                Capsule()
                    .stroke(color.opacity(0.4), lineWidth: 1)
            )
            .accessibilityLabel("\(section.rawValue) section")
    }
}

struct ColoredTagChip: View {
    let tag: String
    var showDelete: Bool = false
    var onDelete: (() -> Void)?

    private var tagColor: Color {
        Color.tagColor(for: tag)
    }

    var body: some View {
        HStack(spacing: 4) {
            Text(tag)
                .font(.bakeryBody(12))
                .foregroundColor(.flourWhite)

            if showDelete, let onDelete = onDelete {
                Button(action: onDelete) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.flourWhite.opacity(0.9))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Remove \(tag) tag")
            }
        }
        .padding(.horizontal, Spacing.sm + 2)
        .padding(.vertical, Spacing.xs + 2)
        .background(
            Capsule()
                .fill(tagColor)
        )
        // Extend touch target beyond visual bounds for accessibility
        .contentShape(Capsule().inset(by: -8))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(showDelete ? "\(tag) tag, removable" : "\(tag) tag")
    }
}

struct ColoredTagChipOutlined: View {
    let tag: String

    private var tagColor: Color {
        Color.tagColor(for: tag)
    }

    var body: some View {
        Text(tag)
            .font(.bakeryBody(11))
            .foregroundColor(tagColor)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(
                Capsule()
                    .fill(tagColor.opacity(0.15))
            )
    }
}

// MARK: - Empty State View

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: icon)
                .font(.system(size: 48, weight: .light))
                .foregroundColor(.crustBrown.opacity(0.5))
                .accessibilityHidden(true)

            VStack(spacing: Spacing.sm) {
                Text(title)
                    .font(.bakeryTitle)
                    .foregroundColor(.inkBrown)

                Text(message)
                    .font(.bakeryBodyDynamic)
                    .foregroundColor(.stoneGray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.xl)
            }

            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                }
                .buttonStyle(SoftButtonStyle(isAccent: true))
                .padding(.top, Spacing.sm)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.panCream)
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Editable Card Section (with tap-to-edit affordance)

/// A card section that provides visual hints that it's editable
struct EditableCardSection<Content: View>: View {
    let title: String
    var isEmpty: Bool = false
    var emptyText: String = "Tap to add..."
    var isEditable: Bool = true
    let onTap: () -> Void
    @ViewBuilder let content: () -> Content

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: Spacing.md) {
                HStack {
                    Text(title)
                        .sectionHeader()

                    Spacer()

                    if isEditable {
                        Image(systemName: "pencil")
                            .font(.system(size: 12))
                            .foregroundColor(.stoneGray.opacity(0.6))
                    }
                }

                if isEmpty {
                    Text(emptyText)
                        .font(.bakeryBodyDynamic)
                        .foregroundColor(.stoneGray)
                        .italic()
                } else {
                    content()
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(Spacing.lg)
            .warmCard()
        }
        .buttonStyle(.plain)
        .disabled(!isEditable)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(isEmpty ? "\(title), empty" : title)
        .accessibilityHint(isEditable ? "Double tap to edit" : "")
        .accessibilityAddTraits(isEditable ? .isButton : [])
    }
}

// MARK: - Animated Background

struct WarmGradientBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color.panCream,
                Color.panCrumb.opacity(0.3),
                Color.panCream
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

// MARK: - Preview

#Preview("Theme Components") {
    ScrollView {
        VStack(spacing: Spacing.xl) {
            // Typography
            VStack(alignment: .leading, spacing: Spacing.md) {
                Text("Typography")
                    .sectionHeader()

                Text("Shokupan")
                    .font(.bakerySerif(32))
                    .foregroundColor(.inkBrown)

                Text("The Art of Bread Making")
                    .font(.bakerySerifMedium(20))
                    .foregroundColor(.warmBrown)

                Text("A calm, zen approach to baking")
                    .font(.bakeryBody(16))
                    .foregroundColor(.stoneGray)

                Text("250g flour • 70% hydration")
                    .font(.bakeryMono(14))
                    .foregroundColor(.warmBrown)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(Spacing.lg)
            .warmCard()

            // Badges
            VStack(alignment: .leading, spacing: Spacing.md) {
                Text("Badges")
                    .sectionHeader()

                HStack(spacing: Spacing.md) {
                    HydrationIndicator(percentage: 70)
                    FlourWeightBadge(weight: "250g")
                    SectionBadge(section: .preferment)
                    SectionBadge(section: .finalDough)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(Spacing.lg)
            .warmCard()

            // Tags
            VStack(alignment: .leading, spacing: Spacing.md) {
                Text("Tags")
                    .sectionHeader()

                VStack(alignment: .leading, spacing: Spacing.sm) {
                    HStack(spacing: Spacing.sm) {
                        ColoredTagChip(tag: "japanese")
                        ColoredTagChip(tag: "milk bread")
                        ColoredTagChip(tag: "sourdough")
                        ColoredTagChip(tag: "artisan")
                    }
                    HStack(spacing: Spacing.sm) {
                        ColoredTagChip(tag: "enriched")
                        ColoredTagChip(tag: "poolish")
                        ColoredTagChip(tag: "tangzhong")
                        ColoredTagChip(tag: "brioche")
                    }
                }

                Text("Outlined variant")
                    .font(.bakeryBody(12))
                    .foregroundColor(.stoneGray)
                    .padding(.top, Spacing.sm)

                HStack(spacing: Spacing.sm) {
                    ColoredTagChipOutlined(tag: "japanese")
                    ColoredTagChipOutlined(tag: "milk bread")
                    ColoredTagChipOutlined(tag: "sourdough")
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(Spacing.lg)
            .warmCard()

            // Buttons
            VStack(alignment: .leading, spacing: Spacing.md) {
                Text("Buttons")
                    .sectionHeader()

                HStack(spacing: Spacing.md) {
                    Button("Secondary") {}
                        .buttonStyle(SoftButtonStyle())

                    Button("Primary") {}
                        .buttonStyle(SoftButtonStyle(isAccent: true))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(Spacing.lg)
            .warmCard()
        }
        .padding(Spacing.lg)
    }
    .background(WarmGradientBackground())
}
