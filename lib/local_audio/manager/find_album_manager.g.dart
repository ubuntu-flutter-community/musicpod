// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'find_album_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FindAlbumManager)
final findAlbumManagerProvider = FindAlbumManagerFamily._();

final class FindAlbumManagerProvider
    extends $AsyncNotifierProvider<FindAlbumManager, List<Audio>?> {
  FindAlbumManagerProvider._({
    required FindAlbumManagerFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'findAlbumManagerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$findAlbumManagerHash();

  @override
  String toString() {
    return r'findAlbumManagerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  FindAlbumManager create() => FindAlbumManager();

  @override
  bool operator ==(Object other) {
    return other is FindAlbumManagerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$findAlbumManagerHash() => r'8abf8423c1676b211dcf5017a7f4bad6a5f886d7';

final class FindAlbumManagerFamily extends $Family
    with
        $ClassFamilyOverride<
          FindAlbumManager,
          AsyncValue<List<Audio>?>,
          List<Audio>?,
          FutureOr<List<Audio>?>,
          int
        > {
  FindAlbumManagerFamily._()
    : super(
        retry: null,
        name: r'findAlbumManagerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FindAlbumManagerProvider call(int albumId) =>
      FindAlbumManagerProvider._(argument: albumId, from: this);

  @override
  String toString() => r'findAlbumManagerProvider';
}

abstract class _$FindAlbumManager extends $AsyncNotifier<List<Audio>?> {
  late final _$args = ref.$arg as int;
  int get albumId => _$args;

  FutureOr<List<Audio>?> build(int albumId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Audio>?>, List<Audio>?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Audio>?>, List<Audio>?>,
              AsyncValue<List<Audio>?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
