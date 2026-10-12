// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'podcast_clean_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PodcastCleanManager)
final podcastCleanManagerProvider = PodcastCleanManagerProvider._();

final class PodcastCleanManagerProvider
    extends $NotifierProvider<PodcastCleanManager, AsyncValue<Set<String>?>> {
  PodcastCleanManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'podcastCleanManagerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$podcastCleanManagerHash();

  @$internal
  @override
  PodcastCleanManager create() => PodcastCleanManager();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<Set<String>?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<Set<String>?>>(value),
    );
  }
}

String _$podcastCleanManagerHash() =>
    r'58959e885790c75fa814abefdf146f0333de81e0';

abstract class _$PodcastCleanManager
    extends $Notifier<AsyncValue<Set<String>?>> {
  AsyncValue<Set<String>?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<Set<String>?>, AsyncValue<Set<String>?>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Set<String>?>, AsyncValue<Set<String>?>>,
              AsyncValue<Set<String>?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
