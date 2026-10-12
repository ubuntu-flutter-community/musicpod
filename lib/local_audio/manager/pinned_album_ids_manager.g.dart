// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pinned_album_ids_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PinnedAlbumIDsManager)
final pinnedAlbumIDsManagerProvider = PinnedAlbumIDsManagerProvider._();

final class PinnedAlbumIDsManagerProvider
    extends $AsyncNotifierProvider<PinnedAlbumIDsManager, List<int>> {
  PinnedAlbumIDsManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pinnedAlbumIDsManagerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pinnedAlbumIDsManagerHash();

  @$internal
  @override
  PinnedAlbumIDsManager create() => PinnedAlbumIDsManager();
}

String _$pinnedAlbumIDsManagerHash() =>
    r'bb5f86284542f090f69f17414244926689625c80';

abstract class _$PinnedAlbumIDsManager extends $AsyncNotifier<List<int>> {
  FutureOr<List<int>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<int>>, List<int>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<int>>, List<int>>,
              AsyncValue<List<int>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
