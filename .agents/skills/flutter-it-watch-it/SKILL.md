---
name: flutter-it-watch-it
description: Expert guidance on watch_it reactive widget state management for Flutter. Covers watch functions (watch, watchIt, watchValue, watchStream, watchFuture), handler registration (registerHandler, registerStreamHandler, registerFutureHandler), lifecycle functions (callOnce, createOnce, onDispose), ordering rules, watching cached factories with parameters (param1/param2, per-entity managers), widget granularity, and startup orchestration. Use when building reactive widgets with watch_it, watching ValueListenables/Streams/Futures, or managing widget-scoped state.
metadata:
  author: flutter-it
  version: "1.0"
---

# watch_it Expert - Reactive Widget State Management

**What**: Reactive widgets that auto-rebuild when ValueListenables/Listenables, Streams, or Futures change. Built on get_it. Provides `di` global alias for `GetIt.I`.

**Related skill**: registration/scopes/async-init details live in `get-it-expert`. `dart run skills@ get` only installs skills of *direct* dependencies, so add `get_it` to your pubspec as well, or run `dart run skills@ add flutter-it/flutter_it` to get all flutter_it skills.

## CRITICAL RULES

- **ORDERING**: All `watch*()`, `registerHandler*()`, `createOnce()`, `callOnce()` calls MUST execute in the same order on every build (like React Hooks)
- **Widget type**: Must extend `WatchingWidget` / `WatchingStatefulWidget` or use `WatchItMixin` / `WatchItStatefulWidgetMixin`
- **Never in callbacks**: Don't call watch functions inside builders, callbacks, or event handlers
- `watchValue` selector MUST return a `ValueListenable<R>`, not a bare value
- `createOnce` works in BOTH stateless and stateful widgets
- NEVER watch a type registered with plain `registerFactory`/`registerFactoryParam` — throws `StateError` in debug (every build would get a new instance). Use `registerCachedFactory(Param)`, a singleton, or pass the instance via `target:` (v2.5.0+)
- Passing `param1`/`param2` for a registration that doesn't take params (or combining them with `target:`) throws in debug (v2.5.0+)

## Widget Types

**ALWAYS prefer `WatchingWidget` / `WatchingStatefulWidget`** for new code. Only use the mixin variants (`WatchItMixin` / `WatchItStatefulWidgetMixin`) when:
- The widget needs **additional mixins** (e.g. `TickerProviderStateMixin`)
- You're **adding watch_it to existing code** and don't want to change the base class

```dart
// ✅ DEFAULT - Use WatchingWidget for new stateless widgets
class MyWidget extends WatchingWidget {
  @override
  Widget build(BuildContext context) { ... }
}

// ✅ DEFAULT - Use WatchingStatefulWidget for new stateful widgets
class MyWidget extends WatchingStatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

// ⚠️ ONLY when you need extra mixins or are retrofitting existing code
class MyWidget extends StatelessWidget with WatchItMixin { ... }
class MyWidget extends StatefulWidget with WatchItStatefulWidgetMixin { ... }
```

## Watch Functions

```dart
// watch() - Watch any Listenable you have a reference to (ChangeNotifier, ValueNotifier, etc.)
final manager = watch(myChangeNotifier);            // rebuilds on notifyListeners()
final value = watch(someValueNotifier).value;       // for ValueNotifiers, access .value

// watchIt() - Watch a Listenable registered in get_it (T MUST extend Listenable)
final manager = watchIt<UserManager>();            // rebuilds on any notification
final config = watchIt<Config>(instanceName: 'dev');

// watchValue() - Watch a ValueListenable PROPERTY from a get_it object
// IMPORTANT: T extends Object (NOT Listenable!) — works with ANY class registered in get_it
// IMPORTANT: The selector MUST return a ValueListenable, not a bare value
// Returns the unwrapped value directly (no need to call .value)
final userState = watchValue((UserManager x) => x.userState);    // x.userState is ValueNotifier<UserState>
final isRunning = watchValue((MyManager x) => x.loadCommand.isRunning);  // isRunning is ValueListenable<bool>
// This is the PREFERRED way to watch command properties on non-Listenable managers:
final isLoading = watchValue((AuthManager m) => m.loginCommand.isRunning);  // AuthManager is NOT a Listenable — works!

// watchPropertyValue() - Watch a non-ValueListenable property from a Listenable (T MUST extend Listenable)
// Rebuilds only when the selected value changes (equality check)
final name = watchPropertyValue((UserManager x) => x.userName);  // userName is a plain String on a ChangeNotifier
// Also supports local target:
final name = watchPropertyValue((MyNotifier x) => x.name, target: myLocalNotifier);

// watchStream() - Replace StreamBuilder
// With get_it select (T looked up from get_it, select extracts the Stream):
final snapshot = watchStream(
  (EventBus x) => x.onEvent<LoginEvent>(),
  initialValue: null,
);
// With target: + select: for objects NOT in get_it (select applied to target):
final snapshot = watchStream(
  (MyService x) => x.statusStream,
  target: myLocalService,
  initialValue: Status.idle,
);
// With target: only — when target IS the Stream itself (pass null as select):
final snapshot = watchStream<Stream<AppLocale>, AppLocale>(
  null,
  target: LocaleSettings.getLocaleStream(),
  initialValue: LocaleSettings.currentLocale,
);

// watchFuture() - Replace FutureBuilder
// With get_it select (T looked up from get_it, select extracts the Future):
final snapshot = watchFuture(
  (ApiClient x) => x.fetchConfig(),
  initialValue: defaultConfig,  // REQUIRED
);
// With target: + select: for objects NOT in get_it (select applied to target):
final snapshot = watchFuture(
  (MyService x) => x.loadData(),
  target: myLocalService,
  initialValue: null,
);
// With target: only — when target IS the Future itself (pass null as select):
final snapshot = watchFuture<Future<Config>, Config>(
  null,
  target: someExternalFuture,
  initialValue: defaultConfig,
);
```

## Cached Factories with Parameters (v2.5.0+, requires get_it 9.3.0)

`watchIt`, `watchValue`, `watchPropertyValue`, `watchStream`, `watchFuture`, `registerHandler`, `registerChangeNotifierHandler`, `registerStreamHandler` and `registerFutureHandler` accept `param1`/`param2`, forwarded to `getIt<T>(param1:, param2:)`. Pattern for per-entity managers (one instance per id):

```dart
di.registerCachedFactoryParam<StationManager, String, void>((id, _) => StationManager(id));

// in a WatchingWidget:
final station = watchValue((StationManager m) => m.station, param1: widget.stationId);
```

Alternative to `createOnce(() => StationManager(id))` + `watch(...)`: the instance is shared by all widgets using the same param and cached (weak reference) by get_it; when the param changes between builds, watch_it re-subscribes to the new instance automatically.

## The Ordering Rule

```dart
// ❌ WRONG - Conditional watch changes order
final showDetails = watchValue((Settings x) => x.showDetails);
if (showDetails) {
  final details = watchValue((Data x) => x.details);  // ORDER CHANGES!
}
final count = watchValue((Counter x) => x.count);

// ✅ CORRECT - Always call all watches, use values conditionally
final showDetails = watchValue((Settings x) => x.showDetails);
final details = watchValue((Data x) => x.details);    // Always called
final count = watchValue((Counter x) => x.count);
if (!showDetails) return Text('Count: $count');
return Text('$count - $details');

// ✅ SAFE - Early return (creates separate code path)
final user = watchValue((Auth x) => x.currentUser);
if (user == null) return LoginScreen();  // Early return ok
final name = watchValue((UserData x) => x.name);  // Safe: always after early return
return Text(name);

// ✅ SAFE - Conditional watch as the LAST watch call (no watches follow it)
final showDetails = watchValue((Settings x) => x.showDetails);
final count = watchValue((Counter x) => x.count);
if (showDetails) {
  final details = watchValue((Data x) => x.details);  // Ok: last watch
}
```

## Lifecycle Functions

```dart
// callOnce - Run once on first build (replaces initState logic)
callOnce((context) {
  di<MarketplaceManager>().loadCommand.run();
});

// callOnceAfterThisBuild - Execute after first build completes (safe for navigation)
callOnceAfterThisBuild((context) {
  Navigator.push(context, ...);
});

// callAfterEveryBuild - Execute after every build, with cancel option
callAfterEveryBuild((context, cancel) {
  scrollController.jumpTo(0);
  if (shouldStop) cancel();
});

// createOnce - Create object once, auto-dispose (works in BOTH stateless and stateful)
// Automatically calls dispose() if the object has a dispose method - no callback needed
final controller = createOnce(() => TextEditingController());
final selectedValue = createOnce(() => ValueNotifier<String?>(null));
// Only pass dispose: if you need custom cleanup beyond the object's own dispose()
final dataSource = createOnce(
  () => MyDataSource(),
  dispose: (ds) => ds.customCleanup(),
);

// createOnceAsync - Async creation
final snapshot = createOnceAsync(
  () => loadExpensiveData(),
  initialValue: null,  // REQUIRED
  dispose: (data) => data?.close(),
);

// onDispose - Register cleanup callback
onDispose(() => someSubscription.cancel());
```

## Handlers (Side Effects Without Rebuild)

```dart
// registerHandler - React to ValueListenable changes
// IMPORTANT: T extends Object (NOT Listenable!) — works with ANY class registered in get_it
// The handler's value parameter is FULLY TYPED based on the ValueListenable returned by select
registerHandler(
  select: (MarketplaceManager m) => m.submitCommand.errors,
  handler: (context, error, cancel) {
    // error is typed as CommandError? but handler never fires with null — use !
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: ${error!.error}')),
    );
  },
  executeImmediately: false, // true = call handler with current value now
);

// PREFER select: over target: — select gives you full type inference from the ValueListenable
// target: is ONLY for local Listenables not registered in get_it (e.g. a locally created ValueNotifier)
// When using target: WITHOUT select:, the target MUST be a Listenable and the handler value is typed as Object

// ❌ WRONG - target: with a ValueListenable loses type info, handler value typed as Object
// registerHandler(
//   target: authManager.loginCommand.errors,  // loses type!
//   handler: (context, error, _) {
//     final commandError = error as CommandError;  // ugly cast needed
//   },
// );

// ✅ CORRECT - select: from get_it type, handler value is fully typed
registerHandler(
  select: (AuthManager m) => m.loginCommand.errors,
  handler: (context, error, _) {
    // error is CommandError? — handler never fires with null, use ! to promote
    showError(error!.error.toString());
  },
);

// registerHandler with local target (for Listenables NOT in get_it)
// Use target: + select: together when the Listenable is local
registerHandler(
  target: myLocalNotifier,
  select: (MyNotifier x) => x.someProperty,
  handler: (context, value, cancel) { ... },
);

// registerChangeNotifierHandler - For ChangeNotifier objects (no select, gets the whole object)
registerChangeNotifierHandler<UserManager>(
  handler: (context, manager, cancel) {
    if (manager.isLoggedOut) Navigator.pushReplacementNamed(context, '/login');
  },
);

// registerStreamHandler - For Stream events
registerStreamHandler<EventBus, ComposerEvent>(
  select: (EventBus bus) => bus.on<ComposerEvent>(),
  handler: (context, snapshot, cancel) {
    if (snapshot.hasData) handleEvent(snapshot.data!);
  },
);

// registerFutureHandler - For Future completion
registerFutureHandler<ApiClient, Config>(
  select: (ApiClient api) => api.fetchConfig(),
  handler: (context, snapshot, cancel) {
    if (snapshot.hasData) applyConfig(snapshot.data!);
  },
  callHandlerOnlyOnce: true, // false = handler re-fires on every rebuild after completion
);
```

**allowObservableChange / allowStreamChange / allowFutureChange**: By default `false`, which means the `select` function is only called once on the first build and the result is **cached**. This makes it safe to use derived observables like `listenable.map(...)` or `listenable.where(...)` inside `select` - they won't be recreated on every rebuild. Only set to `true` if you intentionally need to **switch** to a different observable/stream/future between builds (e.g. switching data sources based on state). If the *parent* resolved from get_it is a different instance than on the previous build (cached factory with new params, or a re-registered singleton), watch_it re-subscribes automatically without `allowObservableChange` (v2.5.0+).

## Startup Orchestration

```dart
// Option 1: watch_it allReady() - returns bool, rebuilds reactively
class SplashScreen extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final ready = allReady(
      onReady: (context) => Navigator.pushReplacement(context, ...),
      onError: (context, error) => showErrorDialog(context, error),
      timeout: Duration(seconds: 10),
    );
    if (!ready) return CircularProgressIndicator();
    return MainApp();
  }
}

// Option 2: allReadyHandler (side effect only, no rebuild)
allReadyHandler(
  (context) => Navigator.pushReplacement(context, mainRoute),
  onError: (context, error) => showErrorDialog(context, error),
);
return CircularProgressIndicator(); // Always shows until handler fires

// Option 3: isReady<T>() - Wait for specific type
final dbReady = isReady<Database>(timeout: Duration(seconds: 5));

// Option 4: Without watch_it (FutureBuilder)
FutureBuilder(
  future: getIt.allReady(),
  builder: (context, snapshot) {
    if (!snapshot.hasData) return SplashScreen();
    return MainApp();
  },
);
```

## Scope Management

```dart
// Push scope tied to widget lifetime (auto-popped on dispose)
pushScope(
  init: (getIt) {
    getIt.registerSingleton<PageData>(PageData());
  },
  dispose: () => print('scope cleaned up'),
);

// Rebuild when any scope changes
rebuildOnScopeChanges();
```

## Widget Granularity

A widget watching multiple objects is perfectly fine. Only split into smaller WatchingWidgets when watched values change at **different frequencies** and rebuilds become costly. Keep a balance - don't over-split.

```dart
// ✅ Fine - watching multiple values that change together or in a simple widget
class MyScreen extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final user = watchValue((Auth x) => x.user);
    final count = watchValue((Counter x) => x.count);
    return Column(children: [Header(user), Counter(count)]);
  }
}

// ✅ Split when values change at different frequencies and widget tree is expensive
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(children: [_Header(), _Counter()]);
  }
}
class _Header extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final user = watchValue((Auth x) => x.user);
    return HeaderWidget(user);
  }
}
class _Counter extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final count = watchValue((Counter x) => x.count);
    return CounterWidget(count);
  }
}
```

## Production Patterns

**Command button with loading state**:
```dart
class WcCommandButton extends WatchingWidget {
  final Command command;
  @override
  Widget build(BuildContext context) {
    final isRunning = watch(command.isRunning).value;
    final canRun = watch(command.canRun).value;
    return ElevatedButton(
      onPressed: canRun ? () => command.run() : null,
      child: isRunning ? CircularProgressIndicator() : Text('Submit'),
    );
  }
}
```

**Reacting to command completion** (see also command_it skill):

A Command is itself a ValueListenable with three levels of observation:

```dart
// ✅ BEST — Watch the command itself: fires ONLY on successful completion
registerHandler(
  select: (MyManager m) => m.saveCommand,
  handler: (context, _, __) {
    navigateAway();  // Only called on success
  },
);

// ✅ Watch .errors: fires ONLY on errors
registerHandler(
  select: (MyManager m) => m.saveCommand.errors,
  handler: (context, error, _) {
    showError(error!.error.toString());
  },
);

// Watch .results: fires on EVERY state change (isRunning, success, error)
registerHandler(
  select: (MyManager m) => m.saveCommand.results,
  handler: (context, result, _) {
    if (result.isSuccess) { ... }
    if (result.hasError) { ... }
    if (result.isRunning) { ... }
  },
);

// ❌ DON'T use isRunning to detect success — fragile and ambiguous
registerHandler(
  select: (MyManager m) => m.saveCommand.isRunning,
  handler: (context, isRunning, _) {
    if (!isRunning && noError) { ... }  // Easy to get wrong
  },
);
```

**createOnce for local state**:
```dart
final reasonController = createOnce(() => TextEditingController());
final selectedReason = createOnce(() => ValueNotifier<ReturnReason?>(null));
```

## Debugging

```dart
// Enable tracing for a specific widget (call at top of build)
enableTracing(logRebuilds: true, logHandlers: true, logHelperFunctions: true);
```
