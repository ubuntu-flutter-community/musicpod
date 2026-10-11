// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'find_all_album_i_ds_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FindAllAlbumIDsManager)
final findAllAlbumIDsManagerProvider = FindAllAlbumIDsManagerProvider._();

final class FindAllAlbumIDsManagerProvider
    extends $AsyncNotifierProvider<FindAllAlbumIDsManager, List<int>?> {
  FindAllAlbumIDsManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'findAllAlbumIDsManagerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$findAllAlbumIDsManagerHash();

  @$internal
  @override
  FindAllAlbumIDsManager create() => FindAllAlbumIDsManager();
}

String _$findAllAlbumIDsManagerHash() =>
    r'd31230ac320007467a6292798982f7f289598b69';

abstract class _$FindAllAlbumIDsManager extends $AsyncNotifier<List<int>?> {
  FutureOr<List<int>?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<int>?>, List<int>?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<int>?>, List<int>?>,
              AsyncValue<List<int>?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
