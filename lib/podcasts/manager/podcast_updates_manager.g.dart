// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'podcast_updates_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PodcastUpdatesManager)
final podcastUpdatesManagerProvider = PodcastUpdatesManagerProvider._();

final class PodcastUpdatesManagerProvider
    extends $NotifierProvider<PodcastUpdatesManager, PodcastUpdatesState> {
  PodcastUpdatesManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'podcastUpdatesManagerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$podcastUpdatesManagerHash();

  @$internal
  @override
  PodcastUpdatesManager create() => PodcastUpdatesManager();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PodcastUpdatesState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PodcastUpdatesState>(value),
    );
  }
}

String _$podcastUpdatesManagerHash() =>
    r'7bd71c8d044d42209d7d1edc12287c31f784b244';

abstract class _$PodcastUpdatesManager extends $Notifier<PodcastUpdatesState> {
  PodcastUpdatesState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<PodcastUpdatesState, PodcastUpdatesState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PodcastUpdatesState, PodcastUpdatesState>,
              PodcastUpdatesState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
