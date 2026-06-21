# Design System Master File

> **LOGIC:** When building a specific page, first check `design-system/pages/[page-name].md`.
> If that file exists, its rules **override** this Master file.
> If not, strictly follow the rules below.

---

**Project:** loml.nas.music
**Generated:** 2026-06-19
**Category:** Music Streaming (Navidrome Player)
**Design Theme:** 简约大气 (Minimal Premium)

---

## Global Rules

### Color Palette

| Role | Dark Hex | Light Hex | Usage |
|------|----------|-----------|-------|
| Background | `#1A1A1A` | `#FAFAF9` | Scaffold background |
| Surface | `#121212` | `#FFFFFF` | Cards, sheets, nav |
| Card | `#242424` | `#F5F5F0` | Elevated cards |
| Primary | `#D4A373` | `#B8860B` | Accent, active states |
| Primary Light | `#E6C9A8` | `#D4A373` | Secondary accent |
| Border | `#2E2E2E` | `#E5E5E0` | Dividers, strokes |
| Text Primary | `#F5F5F0` | `#1A1A1A` | Headings, body |
| Text Secondary | `#A0A0A0` | `#555555` | Subtitle, metadata |
| Text Muted | `#666666` | `#999999` | Captions, hints |
| Error | `#EF4444` | `#EF4444` | Errors |
| Success | `#22C55E` | `#16A34A` | Playing indicator |

**Color Notes:** Warm gold accent (#D4A373) on deep charcoal. Minimal, premium, warm. No neon, no vibrant gradients.

### Typography

- **Heading Font:** Outfit (300-700 weight) — geometric, clean, modern, premium
- **Body Font:** Inter (300-700 weight) — highly readable, Swiss minimalism
- **Mood:** Minimal, premium, sophisticated, clean, balanced
- **Google Fonts:** [Outfit](https://fonts.google.com/specimen/Outfit) + [Inter](https://fonts.google.com/specimen/Inter)

### Spacing

| Token | Value | Usage |
|-------|-------|-------|
| `--space-xs` | `4px` | Tiny gaps |
| `--space-sm` | `8px` | Icon gaps |
| `--space-md` | `16px` | Standard padding |
| `--space-lg` | `24px` | Section padding |
| `--space-xl` | `32px` | Large gaps |
| `--space-2xl` | `48px` | Section margins |

### Layout Principles

- **Generous whitespace** — plenty of breathing room between elements
- **Fine borders** — use `0.5px` or `1px` subtle borders, never heavy strokes
- **No unnecessary decoration** — no glassmorphism, no heavy shadows by default
- **Album art as focal point** — let cover images speak, don't overlay decorative elements
- **Information hierarchy** — clear visual priority through typography weight and size, not color

---

## Component Specs

### Buttons

```
Button style: FilledButton (primary), OutlinedButton (secondary)
Border radius: 12px
Padding: horizontal 16-24px, vertical 14px
Transition: color 200ms ease
No hover scale transform
```

### Cards

```
Border radius: 12px
Border: 0.5px solid (dark: #2E2E2E, light: #E5E5E0)
Elevation: 0 (flat design)
Hover: subtle color change on clickable cards
```

### Inputs

```
Border radius: 12px
Filled: true
Fill color: Card color
Focused border: Primary 1.5px
```

### Dividers

```
Thickness: 0.5px
Color: Border color
```

---

## Style Guidelines

**Style:** Minimal Premium with Warm Dark

**Design approach:**
- Clean lines, plenty of whitespace
- Warm dark (#121212) instead of pure black
- Gold accent (#D4A373) as the only color highlight
- Outfit for headings (geometric, distinctive)
- Inter for body (crystal clear readability)
- Subtle transitions (200ms) on color/opacity only
- No scale transforms on hover
- No glassmorphism effects
- No gradient backgrounds
- No neon or glow effects

### Page Pattern

**Internal app UI (not a landing page)**

- Tab-based navigation (Home, Library, Search, Settings)
- Content hierarchy: large album art → heading → metadata → actions
- List/Grid views for browsing
- Full-screen player for Now Playing with minimal UI chrome

---

## Anti-Patterns (Do NOT Use)

- ❌ Emojis as icons — use Material Icons or Lucide-style
- ❌ Glassmorphism / Frosted glass effects
- ❌ Neon glow or cyberpunk effects
- ❌ Heavy box-shadows — prefer flat with fine borders
- ❌ Scale transforms on hover (causes layout shift)
- ❌ Low contrast text (always 4.5:1 minimum)
- ❌ No hover/focus states on interactive elements
- ❌ Busy backgrounds or decorative patterns
- ❌ Gradient overlays on album art
- ❌ Pure black (#000000) backgrounds — use #121212 instead

---

## Pre-Delivery Checklist

- [ ] No emojis as icons (use Material Icons or custom SVGs)
- [ ] Consistent icon sizing (24x24)
- [ ] All clickable elements have visual feedback
- [ ] Hover states with smooth color transitions (200ms)
- [ ] Light mode: text contrast 4.5:1 minimum
- [ ] Dark mode: text contrast 4.5:1 minimum
- [ ] Dark mode: use #121212 not #000000 for backgrounds
- [ ] Focus states visible for keyboard navigation
- [ ] `prefers-reduced-motion` respected
- [ ] Responsive: mobile 375px + tablet/desktop
- [ ] No content hidden behind nav bars
- [ ] No horizontal scroll
- [ ] Album art loading has placeholder state
- [ ] All API errors handled gracefully
