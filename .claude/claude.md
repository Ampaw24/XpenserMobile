
## Core Development Principles

* Always write production-grade, scalable, and maintainable Flutter code.
* Prioritize readability, modularity, and long-term maintainability over shortcuts.
* Follow clean architecture and separation of concerns.
* Avoid unnecessary abstraction for small features.
* Prefer composition over inheritance.
* Keep widgets small and reusable.
* Every screen, service, provider, controller, and model must have a single responsibility.
* Never generate placeholder logic unless explicitly requested.
* Never generate fake APIs or mock implementations in production code.
* Avoid code duplication completely.

---

# Response Optimization Rules (Quota Saving)

## Strict Token Efficiency

* Never explain obvious Flutter concepts unless requested.
* Avoid long prose explanations.
* Return only the necessary code and concise implementation notes.
* Do not repeat unchanged code blocks.
* Only regenerate modified sections.
* Avoid verbose comments inside code.
* Do not explain imports unless requested.
* Avoid generating unnecessary example data.
* Never provide alternative implementations unless requested.
* Avoid repeating user requirements.
* Keep responses implementation-focused.

## Incremental Code Generation

* Modify only affected files/components.
* Avoid rewriting entire screens for small changes.
* Use patch-style updates whenever possible.
* Return delta updates instead of full project rewrites.

## Architecture Awareness

* Respect existing project architecture.
* Reuse existing utilities/services/providers before creating new ones.
* Never introduce a new state management solution unless requested.
* Never create duplicate helpers/utilities.

---

# Flutter Responsiveness Rules (STRICT)

## No Hardcoded Layout Values

DO NOT use fixed constant values for:

* width
* height
* padding
* margin
* spacing
* font sizes
* icon sizes
* border radius
* positioned offsets

Avoid:

```dart
width: 300
height: 200
padding: EdgeInsets.all(20)
SizedBox(height: 30)
fontSize: 18
```

## Required Responsive Approach

Always use:

* MediaQuery
* LayoutBuilder
* Flexible
* Expanded
* FractionallySizedBox
* AspectRatio
* FittedBox
* Wrap
* Spacer
* constraints-based layouts

Preferred scaling patterns:

```dart
final width = MediaQuery.of(context).size.width;
final height = MediaQuery.of(context).size.height;

padding: EdgeInsets.symmetric(
  horizontal: width * 0.04,
  vertical: height * 0.015,
)
```

## Responsive Typography

* Font sizes must scale relative to screen dimensions or use responsive typography utilities.
* Avoid static text sizing.
* Ensure accessibility scaling compatibility.

## Device Compatibility

UI must support:

* small phones
* large phones
* tablets
* landscape mode
* split-screen mode
* foldables

Never assume a fixed screen size.

---

# UI/UX Standards

* Maintain consistent spacing systems.
* Use design tokens or centralized theme constants.
* Prefer adaptive layouts over scroll-heavy fixes.
* Avoid overflow-prone layouts.
* Always account for keyboard insets.
* Use SafeArea appropriately.
* Minimize widget tree depth where possible.

## Animation Rules

* Keep animations performant and subtle.
* Avoid unnecessary rebuilds during animations.
* Use const constructors only where responsiveness is unaffected.

---

# State Management Rules

* Keep business logic outside UI widgets.
* UI widgets must remain presentation-focused.
* Avoid massive controllers/providers/blocs.
* Dispose controllers properly.
* Avoid unnecessary global state.

---

# Performance Rules

* Minimize widget rebuilds.
* Use const constructors selectively.
* Avoid nested scrollables unless necessary.
* Use lazy loading for large lists.
* Optimize image loading and caching.
* Avoid expensive computations inside build methods.
* Debounce search and input listeners.

---

# Networking & API Rules

* Centralize API logic.
* Handle:

  * loading
  * success
  * empty
  * error
  * retry states
* Never hardcode tokens or secrets.
* Always implement proper exception handling.
* Use typed models for API responses.

---

# Code Quality Rules

* Follow Dart lint standards.
* Use meaningful naming conventions.
* Avoid overly abbreviated variable names.
* Prefer final over var where possible.
* Keep methods short and focused.
* Extract repeated UI into reusable widgets.

---

# File Organization Rules

Prefer structure similar to:

```text
lib/
  core/
  services/
  features/
  shared/
  widgets/
  theme/
```

Feature folders should contain:

```text
data/
domain/
presentation/
```

---

# Claude Code Interaction Rules

## Before Generating Code

Always:

1. Analyze existing architecture first.
2. Reuse existing patterns.
3. Check for existing utilities/components.
4. Keep implementations minimal and scalable.

## During Refactoring

* Never break existing APIs unnecessarily.
* Preserve backward compatibility where possible.
* Refactor incrementally.

## When Unsure

* Ask concise clarification questions instead of assuming.
* Do not hallucinate package APIs or project structure.

---

# Forbidden Practices

DO NOT:

* Generate bloated widgets.
* Use massive build methods.
* Hardcode dimensions.
* Mix business logic with UI.
* Add unnecessary dependencies.
* Rewrite stable working code unnecessarily.
* Use deprecated Flutter APIs.
* Create deeply nested widget trees without reason.
* Over-engineer simple features.

---

# Expected Output Style

Claude responses should:

* be concise,
* implementation-focused,
* architecture-aware,
* scalable,
* responsive-first,
* and optimized for minimal token usage.

Return:

* changed files,
* modified sections,
* and short implementation notes only.
