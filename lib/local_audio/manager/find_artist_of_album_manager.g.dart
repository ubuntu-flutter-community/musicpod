// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'find_artist_of_album_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FindArtistOfAlbumManager)
final findArtistOfAlbumManagerProvider = FindArtistOfAlbumManagerFamily._();

final class FindArtistOfAlbumManagerProvider
    extends $AsyncNotifierProvider<FindArtistOfAlbumManager, String?> {
  FindArtistOfAlbumManagerProvider._({
    required FindArtistOfAlbumManagerFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'findArtistOfAlbumManagerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$findArtistOfAlbumManagerHash();

  @override
  String toString() {
    return r'findArtistOfAlbumManagerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  FindArtistOfAlbumManager create() => FindArtistOfAlbumManager();

  @override
  bool operator ==(Object other) {
    return other is FindArtistOfAlbumManagerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$findArtistOfAlbumManagerHash() =>
    r'8b18b02cef7055d0a1b54f47f19b79e3b228000d';

final class FindArtistOfAlbumManagerFamily extends $Family
    with
        $ClassFamilyOverride<
          FindArtistOfAlbumManager,
          AsyncValue<String?>,
          String?,
          FutureOr<String?>,
          int
        > {
  FindArtistOfAlbumManagerFamily._()
    : super(
        retry: null,
        name: r'findArtistOfAlbumManagerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FindArtistOfAlbumManagerProvider call(int albumId) =>
      FindArtistOfAlbumManagerProvider._(argument: albumId, from: this);

  @override
  String toString() => r'findArtistOfAlbumManagerProvider';
}

abstract class _$FindArtistOfAlbumManager extends $AsyncNotifier<String?> {
  late final _$args = ref.$arg as int;
  int get albumId => _$args;

  FutureOr<String?> build(int albumId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<String?>, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<String?>, String?>,
              AsyncValue<String?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
