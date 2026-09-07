# X46 Design System

A modern, premium, minimal design system for **X46 HEALTHTECH**, a technology company building modern software products in healthcare.

## About X46

X46 HEALTHTECH develops innovative digital health solutions designed to empower healthcare professionals and patients. The brand is contemporary, professional, and technology-focused, with an emphasis on trust, clarity, and usability.

## Visual Identity

### Color Palette

The X46 color system is built on a vibrant blue-to-green gradient, reflecting innovation and health:

- **Primary Blue**: `#0052A3` (deep) and `#0099FF` (bright) — trustworthy, professional
- **Secondary Green**: `#4BBF6A` (health-focused) and `#A8D952` (optimistic accent)
- **Teal Accent**: `#17A2A2` — modern, balanced
- **Semantic Colors**: Success, warning, error, info for messaging and feedback
- **Neutral Grays**: Complete range from `#F9FAFB` to `#111827` for text, backgrounds, and borders

### Typography

Uses modern system fonts for clarity and performance:

- **Font Family**: System UI stack (SF Pro Display, Segoe UI, Roboto)
- **Font Mono**: For code and technical content
- **Sizes**: 12px–60px for scalable, accessible type hierarchy
- **Weights**: Light (300) through Bold (700) for emphasis and hierarchy

### Spacing & Layout

Built on an 8px scale:

- **Spacing tokens**: `--spacing-1` (4px) through `--spacing-20` (80px)
- **Radius tokens**: Subtle 4px–16px, plus full 9999px for pills
- **Gaps and padding**: Use CSS custom properties consistently for maintainability

### Shadows & Elevation

Subtle, natural shadows for depth:

- **5-level shadow system**: xs, sm, base, md, lg for elevation
- **Focus ring**: Blue highlight (3px primary color with 1px border)

### Motion & Interaction

Smooth, purposeful transitions:

- **Durations**: Fast (150ms), base (200ms), slow (300ms)
- **Easing**: In-out cubic-bezier for natural motion
- **Hover states**: Color shifts, shadow elevation, subtle opacity changes
- **Disabled states**: Muted colors and reduced opacity

## Content Fundamentals

### Copy Tone & Style

- **Voice**: Professional yet approachable; clear and direct
- **Casing**: Title case for headers; sentence case for body and UI labels
- **Pronouns**: You-focused language; action-oriented verbs
- **Emoji**: Minimal use; emoji excluded from formal healthcare UI (labels, buttons, warnings)
- **Length**: Concise, scannable; avoid jargon unless necessary

### Visual Motifs

- **Imagery**: Clean, human-centric photos; healthcare scenarios without stereotypes
- **Icons**: Lucide or Heroicons style (2px stroke, consistent weight)
- **Patterns**: Subtle gradients reserved for accents; no busy patterns or textures
- **Backgrounds**: Mostly white or light gray; full-bleed imagery only on hero sections
- **Transparency & Blur**: Reserved for modals and overlays; never on body text

## Foundations

See the **Design System** tab for specimen cards covering:

- **Colors**: Primary, secondary, semantic, and neutral palettes
- **Typography**: Size, weight, and line-height specimens
- **Spacing**: Responsive gap and padding examples
- **Components**: Buttons, inputs, cards, badges, and more

## Components

Reusable UI primitives organized by category:

- **Forms**: Button, Input, Select, Checkbox, Radio, Switch
- **Feedback**: Badge, Toast, Tooltip, Alert
- **Layout**: Card, Container
- **Navigation**: Tabs, Breadcrumbs

Each component is carefully designed for accessibility, consistency, and developer ease.

## Accessibility

- **WCAG 2.1 AA** compliance minimum for all components
- **Color contrast**: 4.5:1 for text, 3:1 for large text
- **Touch targets**: 44px minimum for interactive elements
- **Keyboard navigation**: Full support for all interactive components
- **Focus indicators**: Visible, blue-highlighted focus ring on all focusable elements

## Usage

### For Designers

Import `styles.css` to access all tokens (colors, typography, spacing, shadows). Use the component specimens to understand variants and states.

### For Developers

```html
<link rel="stylesheet" href="path/to/styles.css">
<script src="path/to/_ds_bundle.js"></script>
<script>
  const { Button, Input, Card } = window.X46;
  // Use components
</script>
```

All components are exported via `window.X46` namespace after the bundle loads.

## File Structure

```
/
├── styles.css              # Global stylesheet (imports all tokens)
├── tokens/
│   ├── colors.css
│   ├── typography.css
│   ├── spacing.css
│   ├── shadows.css
│   └── transitions.css
├── assets/
│   └── logo.jpeg           # X46 brand mark
├── components/
│   ├── forms/
│   ├── feedback/
│   ├── layout/
│   └── navigation/
└── README.md               # This file
```

## Design System Generation

This design system is compiled automatically. Do not edit:
- `_ds_bundle.js`
- `_ds_manifest.json`
- `_adherence.oxlintrc.json`

These files are regenerated on each build from component source files.

---

**Last updated**: August 2026
