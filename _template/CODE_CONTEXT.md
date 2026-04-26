---
created: {{CREATED_DATE}}
type: reference
tags: [code, dev]
aliases: [code context]
---

# Code Context — {{PROJECT_NAME}}

> File the AI reads before writing/modifying code. Auto-loaded upon entering SDD Phase 5 IMPLEMENT.
> Code examples > descriptions. A one-line code example is better than three lines of description.

---

## Tech Stack

| Layer | Technology | Version |
|-------|-----------|---------|
| Language | {{LANGUAGE}} | {{VERSION}} |
| Framework | {{FRAMEWORK}} | {{VERSION}} |
| Database | {{DATABASE}} | {{VERSION}} |
| Styling | {{STYLING}} | {{VERSION}} |
| Testing | {{TEST_FRAMEWORK}} | {{VERSION}} |
| Package Manager | {{PACKAGE_MANAGER}} | — |

---

## Architecture

### Structure Management

- This file is the curated source-of-truth for architecture, routing rules, and coding patterns.
- The detailed repository snapshot is generated into `docs/reference/repo-structure.md`.
- Refresh the snapshot with `bash scripts/generate-repo-structure.sh` whenever folders or route groups move.

### Project Structure

```
src/
├── {{DIR_1}}/          # {{DIR_1_DESCRIPTION}}
├── {{DIR_2}}/          # {{DIR_2_DESCRIPTION}}
├── {{DIR_3}}/          # {{DIR_3_DESCRIPTION}}
├── {{DIR_4}}/          # {{DIR_4_DESCRIPTION}}
└── {{DIR_5}}/          # {{DIR_5_DESCRIPTION}}
```

### Key Patterns

<!-- Patterns used repeatedly in the project. Include code examples. -->

**Example: [Pattern Name]**
```{{LANGUAGE}}
// {{PATTERN_EXAMPLE}}
```

---

## Commands

```bash
# Development
{{DEV_COMMAND}}              # Start development server

# Build
{{BUILD_COMMAND}}            # Production build

# Test
{{TEST_COMMAND}}             # Full test suite
{{TEST_WATCH_COMMAND}}       # Watch mode

# Lint & Format
{{LINT_COMMAND}}             # Lint
{{FORMAT_COMMAND}}           # Format
```

---

## Coding Conventions

### Naming

| Target | Rule | Example |
|------|------|------|
| File (Component) | {{FILE_CONVENTION}} | `UserProfile.tsx` |
| File (Utility) | {{UTIL_CONVENTION}} | `format-date.ts` |
| Function | camelCase | `getUserData()` |
| Class/Type | PascalCase | `UserService` |
| Constant | UPPER_SNAKE_CASE | `MAX_RETRY_COUNT` |
| CSS Class | {{CSS_CONVENTION}} | `btn-primary` |

### Import Order

```{{LANGUAGE}}
// 1. Framework/Runtime
// 2. External libraries
// 3. Internal modules (absolute path)
// 4. Types
// 5. Styles
```

### Formatting

- Indentation: {{INDENT}} spaces
- Quotes: {{QUOTES}}
- Semicolons: {{SEMICOLONS}}
- Line length: {{LINE_LENGTH}} chars

---

## Constraints

### Never Do

- <!-- Example: Do not use `<img>`, use `next/image` -->
- <!-- Example: No `any` types -->
- <!-- Example: No inline styles, use CSS modules or Tailwind -->
- <!-- Example: No hardcoding environment variables -->

### Always Do

- <!-- Example: Use custom error classes for error handling -->
- <!-- Example: Use standard response format for API responses -->
- <!-- Example: Include a11y attributes in new components -->

### Ask First

- <!-- Example: Adding a new external dependency -->
- <!-- Example: Changing DB schema -->
- <!-- Example: Changing auth/permission logic -->

---

## Common Tasks

### Add new {{COMPONENT_TYPE}}

```bash
# 1. File creation path
{{COMPONENT_PATH}}

# 2. Basic structure
```

```{{LANGUAGE}}
// {{COMPONENT_TEMPLATE}}
```

### Add new API Endpoint

```bash
# 1. File creation path
{{API_PATH}}

# 2. Route registration
{{ROUTE_REGISTRATION}}
```

---

## Performance Targets

<!-- Keep only the items relevant to the project -->

- Lighthouse: > {{LIGHTHOUSE_SCORE}}
- Bundle size: < {{BUNDLE_SIZE}}
- LCP: < {{LCP_TARGET}}
- Test coverage: > {{COVERAGE_TARGET}}%

---

*This file is updated as the project progresses. Add new patterns when discovered.*
*Auto-loaded in SDD Phase 5. Do not read during /start.*
