import SwiftUI

// MARK: - Shokupan Design System
// A wabi-sabi inspired theme: warm, minimal, and serene

// MARK: - Color Palette
extension Color {
    // Primary backgrounds - warm cream tones
    static let panCream = Color(red: 0.98, green: 0.96, blue: 0.92)
    static let panCrumb = Color(red: 0.95, green: 0.92, blue: 0.86)

    // Accent - terracotta and warm browns
    static let crustBrown = Color(red: 0.76, green: 0.60, blue: 0.42)
    static let terracotta = Color(red: 0.80, green: 0.52, blue: 0.40)
    static let warmBrown = Color(red: 0.45, green: 0.35, blue: 0.28)

    // Text colors
    static let inkBrown = Color(red: 0.25, green: 0.22, blue: 0.20)
    static let stoneGray = Color(red: 0.55, green: 0.52, blue: 0.48)

    // Supporting colors
    static let flourWhite = Color(red: 1.0, green: 0.99, blue: 0.97)
    static let yeastGold = Color(red: 0.85, green: 0.72, blue: 0.45)
    static let steamWhite = Color(red: 0.98, green: 0.97, blue: 0.95).opacity(0.9)

    // Semantic colors
    static let prefermentColor = Color(red: 0.72, green: 0.65, blue: 0.55)
    static let finalDoughColor = Color(red: 0.80, green: 0.52, blue: 0.40)

    // Tag colors - Studio Ghibli inspired pastel palette
    static let tagColors: [Color] = [
        Color(red: 0.85, green: 0.42, blue: 0.38),  // Ghibli red (Spirited Away)
        Color(red: 0.55, green: 0.75, blue: 0.55),  // Totoro green
        Color(red: 0.45, green: 0.60, blue: 0.80),  // Sky blue (Howl's)
        Color(red: 0.80, green: 0.60, blue: 0.45),  // Warm tan (Totoro)
        Color(red: 0.65, green: 0.50, blue: 0.65),  // Dusty purple
        Color(red: 0.35, green: 0.55, blue: 0.50),  // Forest green (Mononoke)
        Color(red: 0.75, green: 0.55, blue: 0.55),  // Dusty rose
        Color(red: 0.50, green: 0.58, blue: 0.70),  // Slate blue (Wind Rises)
        Color(red: 0.70, green: 0.55, blue: 0.40),  // Caramel brown
        Color(red: 0.55, green: 0.70, blue: 0.70),  // Seafoam teal
        Color(red: 0.80, green: 0.50, blue: 0.45),  // Coral (Kiki's)
        Color(red: 0.45, green: 0.65, blue: 0.55),  // Sage green
    ]

    /// Returns a consistent color for a given tag string
    static func tagColor(for tag: String) -> Color {
        let hash = abs(tag.lowercased().hashValue)
        return tagColors[hash % tagColors.count]
    }
}

// MARK: - Typography
extension Font {
    // Display fonts - for titles and headers
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
                .font(.bakeryMono(13))
                .foregroundColor(.warmBrown)
        }
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, Spacing.xs)
        .background(
            Capsule()
                .fill(Color.terracotta.opacity(0.12))
        )
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
                .font(.bakeryMono(13))
                .foregroundColor(.warmBrown)
        }
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, Spacing.xs)
        .background(
            Capsule()
                .fill(Color.crustBrown.opacity(0.12))
        )
    }
}

struct SectionBadge: View {
    let section: IngredientSection

    var color: Color {
        switch section {
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
                    Image(systemName: "xmark")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(.flourWhite.opacity(0.8))
                }
            }
        }
        .padding(.horizontal, Spacing.sm + 2)
        .padding(.vertical, Spacing.xs + 2)
        .background(
            Capsule()
                .fill(tagColor)
        )
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

            VStack(spacing: Spacing.sm) {
                Text(title)
                    .font(.bakerySerifMedium(20))
                    .foregroundColor(.inkBrown)

                Text(message)
                    .font(.bakeryBody(15))
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

                FlowLayout(spacing: Spacing.sm) {
                    ColoredTagChip(tag: "japanese")
                    ColoredTagChip(tag: "milk bread")
                    ColoredTagChip(tag: "sourdough")
                    ColoredTagChip(tag: "artisan")
                    ColoredTagChip(tag: "enriched")
                    ColoredTagChip(tag: "poolish")
                    ColoredTagChip(tag: "tangzhong")
                    ColoredTagChip(tag: "brioche")
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
