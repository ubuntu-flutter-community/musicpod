// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'album_ids_of_artist_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AlbumIDsOfArtistManager)
final albumIDsOfArtistManagerProvider = AlbumIDsOfArtistManagerFamily._();

final class AlbumIDsOfArtistManagerProvider
    extends $AsyncNotifierProvider<AlbumIDsOfArtistManager, List<int>?> {
  AlbumIDsOfArtistManagerProvider._({
    required AlbumIDsOfArtistManagerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'albumIDsOfArtistManagerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$albumIDsOfArtistManagerHash();

  @override
  String toString() {
    return r'albumIDsOfArtistManagerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  AlbumIDsOfArtistManager create() => AlbumIDsOfArtistManager();

  @override
  bool operator ==(Object other) {
    return other is AlbumIDsOfArtistManagerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$albumIDsOfArtistManagerHash() =>
    r'78a4c889bcc2ca118c87f16ba5fd840853cd8ef3';

final class AlbumIDsOfArtistManagerFamily extends $Family
    with
        $ClassFamilyOverride<
          AlbumIDsOfArtistManager,
          AsyncValue<List<int>?>,
          List<int>?,
          FutureOr<List<int>?>,
          String
        > {
  AlbumIDsOfArtistManagerFamily._()
    : super(
        retry: null,
        name: r'albumIDsOfArtistManagerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AlbumIDsOfArtistManagerProvider call(String artist) =>
      AlbumIDsOfArtistManagerProvider._(argument: artist, from: this);

  @override
  String toString() => r'albumIDsOfArtistManagerProvider';
}

abstract class _$AlbumIDsOfArtistManager extends $AsyncNotifier<List<int>?> {
  late final _$args = ref.$arg as String;
  String get artist => _$args;

  FutureOr<List<int>?> build(String artist);
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
    return element.handleCreate(ref, () => build(_$args));
  }
}
