---
date: 2026-06-16 11:00
description: A tiny result builder example — and a check that code highlighting works.
---
# A result builder in a couple of minutes

`@resultBuilder` lets you describe a declarative DSL right in Swift — it's
exactly what SwiftUI is built on. A minimal example that assembles a string:

```swift
@resultBuilder
struct GreetingBuilder {
    static func buildBlock(_ parts: String...) -> String {
        parts.joined(separator: " ")
    }
}

func greet(@GreetingBuilder _ make: () -> String) -> String {
    // Assemble the greeting from separate pieces
    make()
}

let message = greet {
    "Hello,"
    "Sergey!"
    "This is a syntax highlighting demo."
}

print(message) // "Hello, Sergey! This is a syntax highlighting demo."
```

Keywords, types, strings and comments are highlighted — courtesy of the
**Splash** plugin wired into the pipeline.
