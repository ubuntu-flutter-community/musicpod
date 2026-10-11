// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'find_album_id_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FindAlbumIdManager)
final findAlbumIdManagerProvider = FindAlbumIdManagerFamily._();

final class FindAlbumIdManagerProvider
    extends $AsyncNotifierProvider<FindAlbumIdManager, int?> {
  FindAlbumIdManagerProvider._({
    required FindAlbumIdManagerFamily super.from,
    required ({String artist, String album}) super.argument,
  }) : super(
         retry: null,
         name: r'findAlbumIdManagerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$findAlbumIdManagerHash();

  @override
  String toString() {
    return r'findAlbumIdManagerProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  FindAlbumIdManager create() => FindAlbumIdManager();

  @override
  bool operator ==(Object other) {
    return other is FindAlbumIdManagerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$findAlbumIdManagerHash() =>
    r'dbc7c5dc9cba4fa20d11f27d48748886fd4a373a';

final class FindAlbumIdManagerFamily extends $Family
    with
        $ClassFamilyOverride<
          FindAlbumIdManager,
          AsyncValue<int?>,
          int?,
          FutureOr<int?>,
          ({String artist, String album})
        > {
  FindAlbumIdManagerFamily._()
    : super(
        retry: null,
        name: r'findAlbumIdManagerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FindAlbumIdManagerProvider call({
    required String artist,
    required String album,
  }) => FindAlbumIdManagerProvider._(
    argument: (artist: artist, album: album),
    from: this,
  );

  @override
  String toString() => r'findAlbumIdManagerProvider';
}

abstract class _$FindAlbumIdManager extends $AsyncNotifier<int?> {
  late final _$args = ref.$arg as ({String artist, String album});
  String get artist => _$args.artist;
  String get album => _$args.album;

  FutureOr<int?> build({required String artist, required String album});
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<int?>, int?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<int?>, int?>,
              AsyncValue<int?>,
              Object?,
              Object?
            >;
    return element.handleCreate(
      ref,
      () => build(artist: _$args.artist, album: _$args.album),
    );
  }
}
