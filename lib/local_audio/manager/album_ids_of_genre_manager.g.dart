// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'album_ids_of_genre_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AlbumIDsOfGenreManager)
final albumIDsOfGenreManagerProvider = AlbumIDsOfGenreManagerFamily._();

final class AlbumIDsOfGenreManagerProvider
    extends $AsyncNotifierProvider<AlbumIDsOfGenreManager, List<int>?> {
  AlbumIDsOfGenreManagerProvider._({
    required AlbumIDsOfGenreManagerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'albumIDsOfGenreManagerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$albumIDsOfGenreManagerHash();

  @override
  String toString() {
    return r'albumIDsOfGenreManagerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  AlbumIDsOfGenreManager create() => AlbumIDsOfGenreManager();

  @override
  bool operator ==(Object other) {
    return other is AlbumIDsOfGenreManagerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$albumIDsOfGenreManagerHash() =>
    r'ff071fdc8e5a915423c1b8b172277d555383a43a';

final class AlbumIDsOfGenreManagerFamily extends $Family
    with
        $ClassFamilyOverride<
          AlbumIDsOfGenreManager,
          AsyncValue<List<int>?>,
          List<int>?,
          FutureOr<List<int>?>,
          String
        > {
  AlbumIDsOfGenreManagerFamily._()
    : super(
        retry: null,
        name: r'albumIDsOfGenreManagerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AlbumIDsOfGenreManagerProvider call(String genre) =>
      AlbumIDsOfGenreManagerProvider._(argument: genre, from: this);

  @override
  String toString() => r'albumIDsOfGenreManagerProvider';
}

abstract class _$AlbumIDsOfGenreManager extends $AsyncNotifier<List<int>?> {
  late final _$args = ref.$arg as String;
  String get genre => _$args;

  FutureOr<List<int>?> build(String genre);
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
