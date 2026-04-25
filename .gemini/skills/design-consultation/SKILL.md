---
name: design-consultation
description: Use to generate or audit a design system (colors, typography, components, spacing) for frontend projects. For new projects or design unification.
---

# /design-consultation — Design System Generation

> Generate a design system (colors, typography, components, spacing) tailored to the project.
> Use when starting a new frontend project or when design unification is needed.

## Usage
```
/design-consultation                     # Extract patterns from existing code
/design-consultation "SaaS Dashboard"    # Specify a theme to generate a new one
/design-consultation --audit             # Audit the current design system
```

## Protocol

### Step 1: Analyze Current State
- Check existing CSS/Tailwind configuration files (`tailwind.config`, `theme.ts`, etc.)
- Collect colors, fonts, and spacing patterns in use
- Check component libraries (shadcn, MUI, Ant, etc.)

### Step 2: Propose Design System
```markdown
## Design System: [Project Name]

### Color Palette
- Primary: #2563EB (Blue 600) — CTA, links, emphasis
- Secondary: #64748B (Slate 500) — secondary text, icons
- Success/Warning/Error: ...
- Background: ...
- Surface: ...

### Typography Scale
- Heading 1: 2.25rem / bold / 1.2 line-height
- Heading 2: 1.875rem / semibold
- Body: 1rem / normal / 1.5 line-height
- Caption: 0.875rem / normal

### Spacing System
- 4px base: 4, 8, 12, 16, 24, 32, 48, 64

### Component Patterns
- Button: primary / secondary / ghost / destructive
- Input: default / error / disabled
- Card: default / interactive / elevated
```

### Step 3: Application
- Create (or update) `DESIGN.md` file
- Suggest modifications to Tailwind/CSS configuration files
- Highlight inconsistencies with existing code

## Notes
- Unnecessary for backend/CLI projects
- If a design system already exists, it is more appropriate to audit it using `/plan-design-review`
