// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'podcast_collection_filter_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PodcastUpdatesOnlyManager)
final podcastUpdatesOnlyManagerProvider = PodcastUpdatesOnlyManagerProvider._();

final class PodcastUpdatesOnlyManagerProvider
    extends $NotifierProvider<PodcastUpdatesOnlyManager, bool> {
  PodcastUpdatesOnlyManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'podcastUpdatesOnlyManagerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$podcastUpdatesOnlyManagerHash();

  @$internal
  @override
  PodcastUpdatesOnlyManager create() => PodcastUpdatesOnlyManager();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$podcastUpdatesOnlyManagerHash() =>
    r'30339779978a018e10f031cef921ff134bffae91';

abstract class _$PodcastUpdatesOnlyManager extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(PodcastDownloadsOnlyManager)
final podcastDownloadsOnlyManagerProvider =
    PodcastDownloadsOnlyManagerProvider._();

final class PodcastDownloadsOnlyManagerProvider
    extends $NotifierProvider<PodcastDownloadsOnlyManager, bool> {
  PodcastDownloadsOnlyManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'podcastDownloadsOnlyManagerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$podcastDownloadsOnlyManagerHash();

  @$internal
  @override
  PodcastDownloadsOnlyManager create() => PodcastDownloadsOnlyManager();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$podcastDownloadsOnlyManagerHash() =>
    r'062da7ad5e41c6fd910dd49941831912f78c0fb7';

abstract class _$PodcastDownloadsOnlyManager extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
