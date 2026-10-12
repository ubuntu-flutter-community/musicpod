// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SearchManager)
final searchManagerProvider = SearchManagerProvider._();

final class SearchManagerProvider
    extends $NotifierProvider<SearchManager, SearchState> {
  SearchManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchManagerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchManagerHash();

  @$internal
  @override
  SearchManager create() => SearchManager();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SearchState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SearchState>(value),
    );
  }
}

String _$searchManagerHash() => r'bd2938b4364379fa6dbcefbbe06cc257111e0fad';

abstract class _$SearchManager extends $Notifier<SearchState> {
  SearchState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<SearchState, SearchState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SearchState, SearchState>,
              SearchState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
