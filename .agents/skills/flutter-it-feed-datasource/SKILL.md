---
name: flutter-it-feed-datasource
description: Expert guidance on implementing paginated feeds and infinite scroll in Flutter using FeedDataSource and PagedFeedDataSource patterns. Covers base feed data source, cursor-based pagination, auto-pagination at length-3, proxy lifecycle with reference counting, feed widget implementation, filtered feeds, event bus integration, and creation with createOnce. Use when building paginated lists, infinite scroll, feed views, or managing proxy lifecycle in feeds.
metadata:
  author: flutter-it
  version: "1.0"
---

# Feed DataSource Expert - Paged Lists & Infinite Scroll

**What**: Pattern for paginated, reactive list/feed widgets using ValueNotifiers and Commands. Integrates with proxy pattern for entity lifecycle management.

## CRITICAL RULES

- Auto-pagination triggers at `items.length - 3` (not at the last item)
- `updateDataCommand` for initial/refresh loads, `requestNextPageCommand` for pagination - separate commands
- When refreshing with proxies: release OLD proxies AFTER replacing with new ones (delay release for animations)
- `itemCount` is a ValueNotifier - watch it to rebuild the list widget
- Feed data sources are typically created with `createOnce` in widgets, NOT registered in get_it
- `getItemAtIndex(index)` both returns the item AND triggers auto-pagination

## Base FeedDataSource

Non-paged feed for finite data sets:

```dart
abstract class FeedDataSource<TItem> {
  FeedDataSource({List<TItem>? initialItems})
      : items = initialItems ?? [];

  final List<TItem> items;
  final _itemCount = CustomValueNotifier<int>(0);
  ValueListenable<int> get itemCount => _itemCount;
  bool updateWasCalled = false;

  late final updateDataCommand = Command.createAsyncNoParamNoResult(
    () async {
      await updateFeedData();
      updateWasCalled = true;
      refreshItemCount();
    },
    errorFilter: const LocalOnlyErrorFilter(),
  );

  ValueListenable<bool> get isFetchingNextPage => updateDataCommand.isRunning;
  ValueListenable<CommandError?> get commandErrors => updateDataCommand.errors;

  /// Subclasses implement - fetch data and populate items list
  Future<void> updateFeedData();

  /// Subclasses implement - compare items for deduplication
  bool itemsAreEqual(TItem item1, TItem item2);

  TItem getItemAtIndex(int index) {
    assert(index >= 0 && index < items.length);
    return items[index];
  }

  void refreshItemCount() {
    _itemCount.value = items.length;
  }

  void addItemAtStart(TItem item) {
    items.insert(0, item);
    refreshItemCount();
  }

  void removeObject(TItem itemToRemove) {
    items.removeWhere((item) => itemsAreEqual(item, itemToRemove));
    refreshItemCount();
  }

  void reset() {
    items.clear();
    updateWasCalled = false;
    refreshItemCount();
  }

  void dispose() {
    _itemCount.dispose();
  }
}
```

## PagedFeedDataSource

Extends FeedDataSource with cursor-based pagination:

```dart
abstract class PagedFeedDataSource<TItem> extends FeedDataSource<TItem> {
  String? nextPageUrl;
  bool? datasetExpired;

  bool get hasNextPage => nextPageUrl != null && datasetExpired != true;

  late final requestNextPageCommand = Command.createAsyncNoParamNoResult(
    () async {
      await requestNextPage();
      refreshItemCount();
    },
    errorFilter: const LocalOnlyErrorFilter(),
  );

  /// Subclasses implement - fetch next page and append to items
  Future<void> requestNextPage();

  /// Call after parsing API response to store next page URL
  void extractNextPageParams(String? url) {
    nextPageUrl = url;
  }

  /// Auto-pagination: triggers when scrolling near the end
  @override
  TItem getItemAtIndex(int index) {
    if (index >= items.length - 3 &&
        commandErrors.value == null &&
        hasNextPage &&
        !requestNextPageCommand.isRunning.value) {
      requestNextPageCommand.run();
    }
    return super.getItemAtIndex(index);
  }

  // Merged loading/error state from both commands
  late final ValueNotifier<bool> _isFetchingNextPage = ValueNotifier(false);
  @override
  ValueListenable<bool> get isFetchingNextPage => _isFetchingNextPage;

  // Listen to both commands and merge their isRunning states
  // _isFetchingNextPage.value = updateDataCommand.isRunning.value ||
  //                              requestNextPageCommand.isRunning.value;

  @override
  void reset() {
    nextPageUrl = null;
    datasetExpired = null;
    super.reset();
  }
}
```

## Concrete Implementation with Proxies

```dart
class PostsFeedSource extends PagedFeedDataSource<PostProxy> {
  PostsFeedSource(this.feedType);
  final PostFeedType feedType;

  @override
  bool itemsAreEqual(PostProxy a, PostProxy b) => a.id == b.id;

  @override
  Future<void> updateFeedData() async {
    final api = PostApi(di<ApiClient>());
    final response = await api.getPosts(type: feedType);
    if (response == null) return;

    // Release old proxies (delay for exit animations)
    final oldItems = List<PostProxy>.from(items);
    items.clear();

    // Create new proxies via manager (increments ref count)
    final proxies = di<PostsManager>().createProxies(response.data);
    items.addAll(proxies);
    extractNextPageParams(response.links?.next);

    // Release old proxies after animations complete
    Future.delayed(const Duration(milliseconds: 1000), () {
      di<PostsManager>().releaseProxies(oldItems);
    });
  }

  @override
  Future<void> requestNextPage() async {
    if (nextPageUrl == null) return;
    final response = await callNextPageWithUrl<PostListResponse>(nextPageUrl!);
    if (response == null) return;

    final proxies = di<PostsManager>().createProxies(response.data);
    items.addAll(proxies);
    extractNextPageParams(response.links?.next);
  }

  // Override to manage reference counting on individual operations
  @override
  void addItemAtStart(PostProxy item) {
    item.incrementReferenceCount();
    super.addItemAtStart(item);
  }

  @override
  void removeObject(PostProxy item) {
    super.removeObject(item);
    di<PostsManager>().releaseProxy(item);
  }
}
```

## Feed Widget

```dart
class FeedView<TItem> extends WatchingWidget {
  const FeedView({
    required this.feedSource,
    required this.itemBuilder,
    this.emptyListWidget,
  });

  final FeedDataSource<TItem> feedSource;
  final Widget Function(BuildContext, TItem) itemBuilder;
  final Widget? emptyListWidget;

  @override
  Widget build(BuildContext context) {
    final itemCount = watch(feedSource.itemCount).value;
    final isFetching = watch(feedSource.isFetchingNextPage).value;

    // Trigger initial load
    callOnce((_) => feedSource.updateDataCommand.run());

    // Error handler
    registerHandler(
      target: feedSource.commandErrors,
      handler: (context, error, _) {
        showErrorSnackbar(context, error.error);
      },
    );

    // Error state with retry
    if (feedSource.commandErrors.value != null && itemCount == 0) {
      return ErrorWidget(
        onRetry: () => feedSource.updateDataCommand.run(),
      );
    }

    // Initial loading
    if (!feedSource.updateWasCalled && isFetching) {
      return Center(child: CircularProgressIndicator());
    }

    // Empty state
    if (itemCount == 0 && feedSource.updateWasCalled) {
      return emptyListWidget ?? Text('No items');
    }

    // List with pull-to-refresh
    return RefreshIndicator(
      onRefresh: () => feedSource.updateDataCommand.runAsync(),
      child: ListView.builder(
        itemCount: itemCount + (isFetching ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= itemCount) {
            return Center(child: CircularProgressIndicator());
          }
          // getItemAtIndex auto-triggers pagination near end
          final item = feedSource.getItemAtIndex(index);
          return itemBuilder(context, item);
        },
      ),
    );
  }
}
```

## Creation Pattern

```dart
// Create with createOnce in the widget that owns the feed
class PostsFeedPage extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final feedSource = createOnce(
      () => PostsFeedSource(PostFeedType.latest),
      dispose: (source) => source.dispose(),
    );

    return FeedView<PostProxy>(
      feedSource: feedSource,
      itemBuilder: (context, post) => PostCard(post: post),
      emptyListWidget: Text('No posts yet'),
    );
  }
}
```

## Filtered Feeds

Same data, different views via filter functions:

```dart
class ChatsListSource extends PagedFeedDataSource<ChatProxy> {
  ChatFilterType _filter = ChatFilterType.ALL;
  String _query = '';

  void setTypeFilter(ChatFilterType filter) {
    _filter = filter;
    updateDataCommand.run();  // Re-fetch with new filter
  }

  void setSearchQuery(String query) {
    _query = query;
    updateDataCommand.run();
  }
}
```

## Event Bus Integration

Feeds can react to events from other parts of the app:

```dart
// In FeedDataSource constructor
di<EventBus>().on<FeedEvent>().listen((event) {
  if (event.feedsToApply.contains(feedId)) {
    switch (event.action) {
      case FeedEventActions.update:
        updateDataCommand.run();
      case FeedEventActions.addItem:
        addItemAtStart(event.data as TItem);
      case FeedEventActions.removeItem:
        removeObject(event.data as TItem);
    }
  }
});

// Trigger from anywhere in the app
di<EventBus>().fire(FeedEvent(
  action: FeedEventActions.addItem,
  data: newPostProxy,
  feedsToApply: [FeedIds.latestPostsFeed, FeedIds.followingPostsFeed],
));
```

## Anti-Patterns

```dart
// ❌ Releasing proxies immediately on refresh (breaks exit animations)
items.clear();
di<Manager>().releaseProxies(oldItems);  // Widgets still animating!
items.addAll(newProxies);

// ✅ Delay release for animations
final oldItems = List.from(items);
items.clear();
items.addAll(newProxies);
Future.delayed(Duration(milliseconds: 1000), () {
  di<Manager>().releaseProxies(oldItems);
});

// ❌ Registering feed in get_it as singleton
di.registerSingleton<PostsFeed>(PostsFeedSource());
// ✅ Create with createOnce in the widget that owns it
final feed = createOnce(() => PostsFeedSource());

// ❌ Manually checking scroll position for pagination
scrollController.addListener(() {
  if (scrollController.position.pixels >= ...) loadMore();
});
// ✅ Auto-pagination via getItemAtIndex triggers at length - 3

// ❌ Single command for both initial load and pagination
// ✅ Separate commands: updateDataCommand + requestNextPageCommand
//    Allows independent loading/error states and restrictions
```
