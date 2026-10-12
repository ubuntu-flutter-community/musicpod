// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'external_playlist_drafts_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ExternalPlaylistDraftsManager)
final externalPlaylistDraftsManagerProvider =
    ExternalPlaylistDraftsManagerProvider._();

final class ExternalPlaylistDraftsManagerProvider
    extends
        $NotifierProvider<
          ExternalPlaylistDraftsManager,
          Map<String, List<Audio>>
        > {
  ExternalPlaylistDraftsManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'externalPlaylistDraftsManagerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$externalPlaylistDraftsManagerHash();

  @$internal
  @override
  ExternalPlaylistDraftsManager create() => ExternalPlaylistDraftsManager();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, List<Audio>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, List<Audio>>>(value),
    );
  }
}

String _$externalPlaylistDraftsManagerHash() =>
    r'4bf50ef2e745efaee430e8723fdf7d67243f4fc4';

abstract class _$ExternalPlaylistDraftsManager
    extends $Notifier<Map<String, List<Audio>>> {
  Map<String, List<Audio>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<Map<String, List<Audio>>, Map<String, List<Audio>>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Map<String, List<Audio>>, Map<String, List<Audio>>>,
              Map<String, List<Audio>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
