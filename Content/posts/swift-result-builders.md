---
date: 2026-06-16 11:00
description: Небольшой пример result builder — и заодно проверка подсветки кода через Splash.
tags: swift
---
# Свой result builder за пару минут

`@resultBuilder` позволяет описывать декларативный DSL прямо на Swift —
именно на нём построен SwiftUI. Минимальный пример, собирающий строку:

```swift
@resultBuilder
struct GreetingBuilder {
    static func buildBlock(_ parts: String...) -> String {
        parts.joined(separator: " ")
    }
}

func greet(@GreetingBuilder _ make: () -> String) -> String {
    // Собираем приветствие из отдельных кусочков
    make()
}

let message = greet {
    "Привет,"
    "Sergey!"
    "Это пример подсветки кода."
}

print(message) // "Привет, Sergey! Это пример подсветки кода."
```

Ключевые слова, типы, строки и комментарии теперь подсвечиваются —
за это отвечает плагин **Splash**, подключённый в пайплайн.
