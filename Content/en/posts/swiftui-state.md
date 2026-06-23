---
date: 2026-06-14 18:30
description: When to use @State, @Binding, @Observable and Environment.
---
# State management in SwiftUI

One of the first questions in SwiftUI is where to store state. Here's the
cheat sheet I use myself:

- **`@State`** — local state owned by the view itself (a toggle, entered text).
  The source of truth lives inside the view.
- **`@Binding`** — a reference to state owned by a parent. The child reads and
  writes it but doesn't store it.
- **`@Observable`** (the Observation macro) — for models with several fields.
  The view re-renders only when the properties it actually reads change.
- **`@Environment`** — for dependencies many screens need at once: theme,
  services, the current user.

The main rule: every piece of state should have exactly one owner. If two views
need the same state — lift it up to a common parent and pass it down via
`@Binding`.
