# Shokupan Design System

A wabi-sabi inspired design system for the Shokupan bread baking app. The aesthetic blends Studio Ghibli warmth, Apple's clean minimalism, and bakery coziness to create a calm, zen feeling.

## Philosophy

**Wabi-sabi** (侘寂) - Finding beauty in imperfection and transience. The design embraces:
- Warm, natural tones reminiscent of bread and baking
- Generous whitespace for breathing room
- Soft, rounded shapes that feel approachable
- Subtle shadows and layering for depth without harshness

---

## Color Palette

### Primary Backgrounds
| Name | Color | Hex | Usage |
|------|-------|-----|-------|
| Pan Cream | ![#FAF5EB](https://via.placeholder.com/20/FAF5EB/FAF5EB) | `rgb(0.98, 0.96, 0.92)` | Main background gradient |
| Pan Crumb | ![#F2EBDB](https://via.placeholder.com/20/F2EBDB/F2EBDB) | `rgb(0.95, 0.92, 0.86)` | Secondary backgrounds, dividers |
| Flour White | ![#FFFDF8](https://via.placeholder.com/20/FFFDF8/FFFDF8) | `rgb(1.0, 0.99, 0.97)` | Cards, input fields |

### Accent Colors
| Name | Color | Hex | Usage |
|------|-------|-----|-------|
| Terracotta | ![#CC8566](https://via.placeholder.com/20/CC8566/CC8566) | `rgb(0.80, 0.52, 0.40)` | Primary accent, buttons, selected states |
| Crust Brown | ![#C2996B](https://via.placeholder.com/20/C2996B/C2996B) | `rgb(0.76, 0.60, 0.42)` | Secondary accent, icons |
| Warm Brown | ![#735947](https://via.placeholder.com/20/735947/735947) | `rgb(0.45, 0.35, 0.28)` | Tertiary accent |

### Text Colors
| Name | Color | Hex | Usage |
|------|-------|-----|-------|
| Ink Brown | ![#403833](https://via.placeholder.com/20/403833/403833) | `rgb(0.25, 0.22, 0.20)` | Primary text, headings |
| Stone Gray | ![#8C857A](https://via.placeholder.com/20/8C857A/8C857A) | `rgb(0.55, 0.52, 0.48)` | Secondary text, labels |

### Semantic Colors
| Name | Color | Usage |
|------|-------|-------|
| Preferment Color | `rgb(0.72, 0.65, 0.55)` | Preferment section badges |
| Final Dough Color | Terracotta | Final dough section badges |
| Yeast Gold | `rgb(0.85, 0.72, 0.45)` | Special highlights |

### Tag Colors
A muted, calm palette for recipe tags. Colors are assigned consistently based on tag name hash.

| Name | RGB | Description |
|------|-----|-------------|
| Warm Clay | `rgb(0.76, 0.60, 0.50)` | Earthy terracotta variant |
| Sage Green | `rgb(0.65, 0.70, 0.62)` | Soft herbal green |
| Dusty Mauve | `rgb(0.70, 0.62, 0.68)` | Muted purple-pink |
| Wheat | `rgb(0.72, 0.68, 0.58)` | Golden grain tone |
| Slate Blue | `rgb(0.60, 0.65, 0.70)` | Cool muted blue |
| Dusty Rose | `rgb(0.75, 0.58, 0.58)` | Soft pink-brown |
| Seafoam | `rgb(0.58, 0.68, 0.65)` | Calm teal-green |
| Mushroom | `rgb(0.68, 0.60, 0.55)` | Neutral earthy brown |

```swift
// Get consistent color for a tag
let color = Color.tagColor(for: "sourdough")
```

---

## Typography

The typography system uses system fonts with specific designs to balance readability with character.

### Font Styles

```swift
// Display - Serif for titles and headers
.bakerySerif(_ size: CGFloat)      // Regular weight
.bakerySerifMedium(_ size: CGFloat) // Medium weight

// Body - Rounded for general text
.bakeryBody(_ size: CGFloat)        // Regular weight
.bakeryBodyMedium(_ size: CGFloat)  // Medium weight

// Monospace - For measurements and numbers
.bakeryMono(_ size: CGFloat)
```

### Usage Guidelines

| Context | Font | Size | Color |
|---------|------|------|-------|
| Page titles | bakerySerifMedium | 24-32 | inkBrown |
| Card titles | bakerySerifMedium | 17-20 | inkBrown |
| Section headers | bakerySerif | 13 | stoneGray (uppercase, tracked) |
| Body text | bakeryBody | 15 | inkBrown |
| Secondary text | bakeryBody | 13-14 | stoneGray |
| Measurements | bakeryMono | 13-16 | warmBrown |
| Input fields | bakeryMono | 16-24 | inkBrown |
| Badges/chips | bakeryBody | 11-13 | varies |

---

## Spacing System

Consistent spacing creates rhythm and hierarchy.

```swift
struct Spacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}
```

### Usage
- **xs (4pt)**: Tight spacing within badges, between icon and text
- **sm (8pt)**: Spacing between related elements, chip padding vertical
- **md (16pt)**: Standard padding, spacing between sections, chip padding horizontal
- **lg (24pt)**: Card internal padding, major section spacing
- **xl (32pt)**: Large section breaks
- **xxl (48pt)**: Page-level spacing, empty states

---

## Corner Radius

```swift
struct CornerRadius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
    static let full: CGFloat = 999  // Capsule
}
```

### Usage
- **sm (8pt)**: Small input fields, nested elements
- **md (12pt)**: Buttons, input fields, small cards
- **lg (16pt)**: Main cards, sheets
- **xl (24pt)**: Large feature cards
- **full**: Badges, tags, circular buttons

---

## Components

### Warm Card
The primary container for content sections.

```swift
.warmCard(elevated: Bool = false)
```

- Background: flourWhite
- Corner radius: lg (16pt)
- Shadow: warmBrown at 4-8% opacity
- Elevated variant has stronger shadow

### Tag Chip (Plain)
Used for filters and small selections (single color).

```swift
.tagChip(selected: Bool = false)
```

- Font: bakeryBody(13)
- Padding: md horizontal, sm vertical
- Shape: Capsule
- Unselected: panCrumb background, warmBrown text
- Selected: terracotta background, flourWhite text

### Colored Tag Chip
Used for recipe tags with unique colors per tag.

```swift
ColoredTagChip(tag: String, showDelete: Bool = false, onDelete: (() -> Void)?)
```

- Font: bakeryBody(12)
- Padding: sm+2 horizontal, xs+2 vertical
- Shape: Capsule with solid fill
- Color: Derived from tag name via `Color.tagColor(for:)`
- Text: flourWhite
- Optional delete button (x icon)

### Colored Tag Chip Outlined
Lighter variant for compact displays (e.g., recipe cards).

```swift
ColoredTagChipOutlined(tag: String)
```

- Font: bakeryBody(11)
- Padding: 6pt horizontal, 2pt vertical
- Shape: Capsule with 15% opacity fill
- Text: Tag color at full opacity

### Section Header
Consistent section labeling.

```swift
.sectionHeader()
```

- Font: bakerySerif(13)
- Color: stoneGray
- Text case: uppercase
- Letter spacing: 1.2pt

### Stat Card
Display key metrics.

```swift
StatCard(icon: String, label: String, value: String)
```

- Centered layout
- Icon: 16pt, terracotta at 80% opacity
- Value: bakeryMono(16), inkBrown
- Label: bakeryBody(11), stoneGray

### Hydration Indicator
Shows hydration percentage with water drop icon.

```swift
HydrationIndicator(percentage: Int)
```

- Capsule shape
- terracotta tinted background (12% opacity)
- Drop icon + percentage

### Flour Weight Badge
Shows flour weight with scale icon.

```swift
FlourWeightBadge(weight: String)
```

- Capsule shape
- crustBrown tinted background (12% opacity)
- Scale icon + weight

### Section Badge
Indicates ingredient section (Preferment/Final Dough).

```swift
SectionBadge(section: IngredientSection)
```

- Outlined capsule
- Color varies by section type

### Empty State View
Full-screen empty state with optional action.

```swift
EmptyStateView(
    icon: String,
    title: String,
    message: String,
    actionTitle: String?,
    action: (() -> Void)?
)
```

### Warm Gradient Background
Page-level background.

```swift
WarmGradientBackground()
```

- Linear gradient from panCream through panCrumb(30%) to panCream
- Direction: top-leading to bottom-trailing

---

## Buttons

### Soft Button Style
Primary button style with pressed state animation.

```swift
.buttonStyle(SoftButtonStyle(isAccent: Bool = false))
```

- Font: bakeryBodyMedium(15)
- Padding: lg horizontal, md vertical
- Corner radius: md
- **Default**: panCrumb background, warmBrown text
- **Accent**: terracotta background, flourWhite text
- Press effect: 97% scale, 90% opacity

### Icon Buttons
Toolbar and action buttons.

- Size: 14-16pt, semibold weight
- Color: terracotta (primary) or stoneGray (secondary)

---

## Layout Patterns

### List Views
- Warm gradient background
- LazyVStack with md spacing
- Horizontal padding: md
- Vertical padding: sm
- Cards with warmCard modifier

### Detail Views
- Warm gradient background
- ScrollView with hidden indicators
- Sections in warm cards
- Hero images: 200-240pt height

### Sheets/Modals
- panCream solid background
- Navigation bar with inline title
- Cancel button: stoneGray
- Confirm button: terracotta, bakeryBodyMedium

### Tab Bar
- Background: flourWhite
- Shadow: panCrumb
- Unselected: stoneGray
- Selected: terracotta

---

## Animations

- Duration: 0.15-0.2s for micro-interactions
- Easing: easeOut
- Button press: scale + opacity
- State changes: withAnimation wrapper

---

## Icons

Use SF Symbols throughout with these weights:
- **Light (thin)**: Large decorative icons, empty states
- **Regular**: Standard icons
- **Semibold**: Action buttons, navigation

Common icons:
- Recipes: `book.closed`
- Templates: `doc.text`
- Settings: `gear`
- Add: `plus`
- Scale: `scalemass`
- Hydration: `drop.fill`
- More: `ellipsis.circle`
- Share: `square.and.arrow.up`
- Delete: `trash`

---

## Dark Mode Considerations

The current palette is optimized for light mode. For dark mode:
- Swap panCream/flourWhite with darker browns
- Increase terracotta saturation slightly
- Ensure sufficient contrast for accessibility
- Keep the warm, cozy feeling

---

## Accessibility

- Minimum touch target: 44pt
- Color contrast: Ensure 4.5:1 for body text
- Support Dynamic Type where possible
- Provide haptic feedback for key interactions

---

## File Reference

All theme definitions are in `Theme.swift`:
- Color extensions
- Font extensions
- Spacing/CornerRadius structs
- View modifiers
- Reusable components
