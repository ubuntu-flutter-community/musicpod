---
name: flutter-it-overview
description: Overview of the flutter_it construction set - modular Flutter packages (get_it, watch_it, command_it, listen_it) that work standalone or together. Use when deciding which flutter_it package to use, understanding package dependencies, or getting oriented with the ecosystem.
metadata:
  author: flutter-it
  version: "1.0"
---

# flutter_it - Construction Set Overview

**What**: Modular Flutter packages that work standalone or together - you choose what you need.

## Package Selection Guide

**Need dependency injection / service locator?**
-> Use `get-it-expert` skill - Register services, singletons, factories, scopes

**Need reactive state management?**
-> Use `watch-it-expert` skill - Widget reactivity with ValueListenable (requires get_it)

**Need command pattern (actions with loading/error states)?**
-> Use `command-it-expert` skill - Async operations as objects (requires listen_it)

**Need ValueListenable operators (map, debounce, where)?**
-> Use `listen-it-expert` skill - Reactive data transformations

**Need architecture guidance?**
-> Use `flutter-architecture-expert` skill - App structure, startup, patterns

**Need paginated feeds / infinite scroll?**
-> Use `feed-datasource-expert` skill - FeedDataSource, paged lists, proxy lifecycle

## Philosophy: Construction Set

**NOT an all-or-nothing framework** - Each package is an independent building block:
- Use one package alone (get_it for DI only)
- Combine multiple (get_it + watch_it for reactive DI)
- Add more later (start with get_it, add watch_it when needed)

## Common Combinations

```dart
// Combination 1: DI only
get_it alone -> Service locator pattern

// Combination 2: Reactive DI
get_it + watch_it -> Reactive widgets with services

// Combination 3: Command pattern
get_it + listen_it + command_it -> Actions with states

// Combination 4: Full ecosystem
get_it + watch_it + listen_it + command_it -> Complete reactive architecture
```

## Dependencies

```
watch_it -> depends on get_it
command_it -> depends on listen_it
listen_it -> standalone
get_it -> standalone
```

## Quick Links

- Documentation: https://flutter-it.dev
- GitHub: https://github.com/flutter-it/{package}
