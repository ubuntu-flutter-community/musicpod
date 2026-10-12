// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playlist_mode_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PlaylistModeManager)
final playlistModeManagerProvider = PlaylistModeManagerProvider._();

final class PlaylistModeManagerProvider
    extends $NotifierProvider<PlaylistModeManager, PlaylistMode> {
  PlaylistModeManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'playlistModeManagerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$playlistModeManagerHash();

  @$internal
  @override
  PlaylistModeManager create() => PlaylistModeManager();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlaylistMode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlaylistMode>(value),
    );
  }
}

String _$playlistModeManagerHash() =>
    r'eb5f5232ef0e44bc8a4a0f9c76fdc57b051c8f6b';

abstract class _$PlaylistModeManager extends $Notifier<PlaylistMode> {
  PlaylistMode build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<PlaylistMode, PlaylistMode>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PlaylistMode, PlaylistMode>,
              PlaylistMode,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
