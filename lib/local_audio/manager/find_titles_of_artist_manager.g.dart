// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'find_titles_of_artist_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FindTitlesOfArtistManager)
final findTitlesOfArtistManagerProvider = FindTitlesOfArtistManagerFamily._();

final class FindTitlesOfArtistManagerProvider
    extends $AsyncNotifierProvider<FindTitlesOfArtistManager, List<Audio>?> {
  FindTitlesOfArtistManagerProvider._({
    required FindTitlesOfArtistManagerFamily super.from,
    required (String, AudioFilter) super.argument,
  }) : super(
         retry: null,
         name: r'findTitlesOfArtistManagerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$findTitlesOfArtistManagerHash();

  @override
  String toString() {
    return r'findTitlesOfArtistManagerProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  FindTitlesOfArtistManager create() => FindTitlesOfArtistManager();

  @override
  bool operator ==(Object other) {
    return other is FindTitlesOfArtistManagerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$findTitlesOfArtistManagerHash() =>
    r'206977b4663f5f09c98fee19aa0c1aa453b92bdd';

final class FindTitlesOfArtistManagerFamily extends $Family
    with
        $ClassFamilyOverride<
          FindTitlesOfArtistManager,
          AsyncValue<List<Audio>?>,
          List<Audio>?,
          FutureOr<List<Audio>?>,
          (String, AudioFilter)
        > {
  FindTitlesOfArtistManagerFamily._()
    : super(
        retry: null,
        name: r'findTitlesOfArtistManagerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FindTitlesOfArtistManagerProvider call(
    String artist, [
    AudioFilter filter = AudioFilter.album,
  ]) => FindTitlesOfArtistManagerProvider._(
    argument: (artist, filter),
    from: this,
  );

  @override
  String toString() => r'findTitlesOfArtistManagerProvider';
}

abstract class _$FindTitlesOfArtistManager
    extends $AsyncNotifier<List<Audio>?> {
  late final _$args = ref.$arg as (String, AudioFilter);
  String get artist => _$args.$1;
  AudioFilter get filter => _$args.$2;

  FutureOr<List<Audio>?> build(
    String artist, [
    AudioFilter filter = AudioFilter.album,
  ]);
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
    return element.handleCreate(ref, () => build(_$args.$1, _$args.$2));
  }
}
