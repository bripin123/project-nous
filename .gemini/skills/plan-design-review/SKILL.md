---
name: plan-design-review
description: Use for UI/UX design audits on frontend projects. Scores 8 dimensions (consistency, accessibility, responsiveness, hierarchy, interaction, performance, typography, spacing) 0-10.
---

# /plan-design-review — Design Audit

> Evaluate UI/UX design across dimensions with a 0-10 score.
> Use during frontend work, UI design, or design system application.

## Usage
```
/plan-design-review                     # Target current frontend code
/plan-design-review src/components/     # Specific directory
/plan-design-review --screenshot        # Screenshot-based review
```

## Evaluation Dimensions (0-10)

| Dimension | Evaluation Criteria |
|------|----------|
| **Consistency** | Unified colors, typography, spacing, and component styles |
| **Accessibility** | Color contrast, keyboard navigation, screen readers, ARIA |
| **Responsiveness** | Mobile/tablet/desktop layout support |
| **Visual Hierarchy** | Is information priority visually clear? |
| **Interaction** | Hover, focus, loading, and error state handling |
| **Performance** | Image optimization, bundle size, rendering efficiency |
| **Typography** | Readability, line height, font size system |
| **Spacing** | Margins, padding, grid system |

## Protocol

### Step 1: Code/Screenshot Analysis
- Check `DESIGN.md` or design system files
- Traverse component files (*.tsx, *.vue, *.svelte, etc.)
- Analyze CSS/Tailwind classes

### Step 2: Scores + Rationale per Dimension
```markdown
## Design Audit Report

| Dimension | Score | Rationale |
|------|------|------|
| Consistency | 7/10 | Mixed 3 button styles, but colors are unified |
| Accessibility | 4/10 | Missing alt attributes in 12 places, 3 contrast ratio failures |
| Responsiveness | 8/10 | Good mobile support, tablet unconfirmed |
| ... | | |

**Overall Score**: 6.5/10
```

### Step 3: Improvement Suggestions
- **AUTO-FIX** (Mechanical): Remove `outline: none`, remove `!important`, fix `font-size < 16px`
- **ASK** (Requires Judgment): Layout changes, color system modifications, component structure changes

## Notes
- Unnecessary for backend-only projects
- If `DESIGN.md` exists, blessed patterns are not flagged
