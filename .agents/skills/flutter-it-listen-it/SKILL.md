---
name: flutter-it-listen-it
description: Expert guidance on listen_it ValueListenable operators and reactive collections for Flutter/Dart. Covers listen(), transformation operators (map, select, where, debounce, async), combining operators (combineLatest, mergeWith), operator chaining, reactive collections (ListNotifier, MapNotifier, SetNotifier), transactions, and CustomValueNotifier. Use when working with ValueListenable transformations, reactive data pipelines, or listen_it collections.
metadata:
  author: flutter-it
  version: "1.0"
---

# listen_it Expert - ValueListenable Operators & Reactive Collections

**What**: Extension methods on ValueListenable/Listenable for transformations, filtering, debouncing. Plus reactive collections. Pure Dart.

## CRITICAL RULES

- Operators return NEW ValueListenable objects - MUST capture the result
- `listen()` signature differs: on `Listenable` gets `(subscription)`, on `ValueListenable` gets `(value, subscription)`
- `mergeWith()` is an INSTANCE method on ValueListenable, NOT a static method
- There is NO `throttle()` operator
- Chains detach from their source when their last listener is removed and re-attach on the next one (v6.0.0+); `.value` is derived from the source on read while detached (except `mergeWith`, which keeps its last value) — never stale, no dangling listener. Keep transformation functions pure: they may run on read.
- Don't create a new chain on every rebuild (e.g. inline in `ValueListenableBuilder`'s `valueListenable:`); create it once (class field, `late final`, watch_it selector — cached per widget instance — or `createOnce`).
- All operators support `{bool lazy = false}`: lazy only delays the first subscription until the first listener; `.value` is derived on read before that, so there is no stale-value trade-off

## listen() - Subscribing to Changes

```dart
// On ValueListenable<T> - receives value AND subscription
final sub = counter.listen((int value, ListenableSubscription subscription) {
  print('New value: $value');
  if (value > 100) subscription.cancel();  // Self-cancel
});
sub.cancel();  // Or cancel externally

// On plain Listenable - receives ONLY subscription (no value)
final sub = myChangeNotifier.listen((ListenableSubscription subscription) {
  print('Something changed');
});
```

## Transformation Operators

All return new `ValueListenable` and support `{bool lazy = false}`:

```dart
final counter = ValueNotifier<int>(0);

// map - Transform values
final doubled = counter.map((x) => x * 2);

// select - Like map but only notifies when result CHANGES (equality check)
final user = ValueNotifier<User>(User('Alice', 30));
final name = user.select((u) => u.name);  // Only fires when name actually changes

// where - Filter values (only propagate when test passes)
final positives = counter.where((x) => x > 0);
final positives = counter.where((x) => x > 0, fallbackValue: 0);  // Default when filtered

// debounce - Delay notifications
final debouncedSearch = searchField.debounce(Duration(milliseconds: 300));

// async - Defer to next frame (prevents setState-during-build)
final deferred = counter.async();
```

## Combining Operators

```dart
// combineLatest - Merge 2 ValueListenables
final firstName = ValueNotifier<String>('Alice');
final lastName = ValueNotifier<String>('Smith');
final fullName = firstName.combineLatest(
  lastName,
  (first, last) => '$first $last',
);

// combineLatest3/4/5/6 - Merge up to 6 sources
final combined = source1.combineLatest3(
  source2, source3,
  (v1, v2, v3) => '$v1-$v2-$v3',
);

// mergeWith - Merge multiple sources of SAME type (instance method)
final merged = source1.mergeWith([source2, source3]);
// Emits whenever any source changes, value is from the source that changed
```

## Chaining Operators

```dart
final processed = searchInput
    .where((text) => text.isNotEmpty)
    .map((text) => text.trim().toLowerCase())
    .debounce(Duration(milliseconds: 300));

processed.listen((query, subscription) {
  performSearch(query);
});
```

## Chain Lifecycle (v6.0.0+)

- **Attach**: on creation (or on first listener with `lazy: true`).
- **Detach**: on last `removeListener` the chain unsubscribes from its source; cascades down through the whole chain.
- **Re-attach**: next `addListener` re-subscribes (cascading up) and resyncs the value from the source *before* the new listener is added - no spurious notification.
- **`.value` while detached** (derived on read): `map`/`select` → `transform(source.value)`; `where` → `source.value` if it passes, else last passing value; `debounce`/`async` → `source.value`; `combineLatest` → `combiner(...)`; `mergeWith` → last received value.
- `dispose()` is only needed to end a chain that still has listeners, or to cancel a pending `debounce` timer / `async` update. A chain without listeners holds no subscription and is simply GC'd.

## Reactive Collections

Auto-notify listeners on mutations:

```dart
// ListNotifier
final items = ListNotifier<String>(data: ['a', 'b', 'c']);
items.add('d');           // Notifies
items.remove('a');        // Notifies
items[0] = 'z';          // Notifies
items.value;              // UnmodifiableListView (read-only access)

// MapNotifier
final settings = MapNotifier<String, dynamic>(data: {'theme': 'dark'});
settings['theme'] = 'light';   // Notifies
settings.remove('theme');      // Notifies

// SetNotifier
final tags = SetNotifier<String>(data: {'flutter', 'dart'});
tags.add('mobile');       // Notifies
tags.remove('dart');      // Notifies
```

**Notification modes**:
```dart
// CustomNotifierMode.always - notify on every operation (default for collections)
// CustomNotifierMode.normal - notify only when value changes (== check)
// CustomNotifierMode.manual - no auto-notification, call notifyListeners() yourself

final items = ListNotifier<String>(
  notificationMode: CustomNotifierMode.always,
);
```

**Transactions** (batch operations, single notification):
```dart
items.startTransAction();
items.add('a');
items.add('b');
items.add('c');
items.endTransAction();  // Single notification for all 3 adds
```

## Anti-Patterns

```dart
// ❌ Not capturing operator result
counter.map((x) => x * 2);  // Lost! Nobody holds a reference
// ✅ Capture it
final doubled = counter.map((x) => x * 2);

// ❌ Creating a chain on every rebuild - new chain object every rebuild
Widget build(context) {
  return ValueListenableBuilder(
    valueListenable: source.map((x) => x * 2),  // New chain every build!
    builder: (context, value, _) => Text('$value'),
  );
}
// ✅ Class field - created once
late final doubled = counter.map((x) => x * 2);
// ✅ watch_it selector - cached per widget instance; when the widget goes away
//    the chain loses its listener and detaches from m.source (v6.0.0+)
final value = watchValue((Model m) => m.source.map((x) => x * 2));

// ❌ Using addListener instead of listen
notifier.addListener(() { print(notifier.value); });
// ✅ Use listen() from listen_it
notifier.listen((value, sub) { print(value); });

// ❌ ValueNotifier.merge (doesn't exist!)
ValueNotifier.merge([a, b], combiner);  // NOT A REAL METHOD
// ✅ Use mergeWith (instance method) or combineLatest
final merged = a.mergeWith([b]);
final combined = a.combineLatest(b, (va, vb) => va + vb);
```

## Production Patterns

**Debounced auto-save**:
```dart
_dataSubscription = _data
    .debounce(const Duration(seconds: 1))
    .listen((_, __) {
  _data.saveDraft();
});
```

**Filtered draft list**:
```dart
final ListNotifier<CommonComposerData> _drafts = ListNotifier(
  notificationMode: CustomNotifierMode.manual,
);

late ValueListenable<List<CommonComposerData>> savedDrafts =
    (_drafts as ValueListenable<List<CommonComposerData>>)
        .map((list) => list.where((e) => e.intentionallySaved).toList());
```

**Error listening on commands**:
```dart
updatePostCommand.errors.listen((error, _) {
  final composerData = error!.paramData;
  composerData?.saveDraft(withIntention: true);
});
```

## CustomValueNotifier

For advanced notification control:

```dart
final notifier = CustomValueNotifier<int>(
  0,
  mode: CustomNotifierMode.normal,      // Only notify on actual changes
  asyncNotification: false,             // true = defer to next frame
);
```
