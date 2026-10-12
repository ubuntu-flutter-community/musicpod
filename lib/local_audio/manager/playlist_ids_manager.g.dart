// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playlist_ids_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PlaylistIDsManager)
final playlistIDsManagerProvider = PlaylistIDsManagerProvider._();

final class PlaylistIDsManagerProvider
    extends $AsyncNotifierProvider<PlaylistIDsManager, List<String>> {
  PlaylistIDsManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'playlistIDsManagerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$playlistIDsManagerHash();

  @$internal
  @override
  PlaylistIDsManager create() => PlaylistIDsManager();
}

String _$playlistIDsManagerHash() =>
    r'3abbfcc8c5dd16db3277b4d641b48fa2f4748d41';

abstract class _$PlaylistIDsManager extends $AsyncNotifier<List<String>> {
  FutureOr<List<String>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<String>>, List<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<String>>, List<String>>,
              AsyncValue<List<String>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
