// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'podcast_genre_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PodcastGenreManager)
final podcastGenreManagerProvider = PodcastGenreManagerFamily._();

final class PodcastGenreManagerProvider
    extends $AsyncNotifierProvider<PodcastGenreManager, String?> {
  PodcastGenreManagerProvider._({
    required PodcastGenreManagerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'podcastGenreManagerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$podcastGenreManagerHash();

  @override
  String toString() {
    return r'podcastGenreManagerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  PodcastGenreManager create() => PodcastGenreManager();

  @override
  bool operator ==(Object other) {
    return other is PodcastGenreManagerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$podcastGenreManagerHash() =>
    r'4f5721cf10d1f3886dbb8178fece5e855f304ffe';

final class PodcastGenreManagerFamily extends $Family
    with
        $ClassFamilyOverride<
          PodcastGenreManager,
          AsyncValue<String?>,
          String?,
          FutureOr<String?>,
          String
        > {
  PodcastGenreManagerFamily._()
    : super(
        retry: null,
        name: r'podcastGenreManagerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PodcastGenreManagerProvider call(String feedUrl) =>
      PodcastGenreManagerProvider._(argument: feedUrl, from: this);

  @override
  String toString() => r'podcastGenreManagerProvider';
}

abstract class _$PodcastGenreManager extends $AsyncNotifier<String?> {
  late final _$args = ref.$arg as String;
  String get feedUrl => _$args;

  FutureOr<String?> build(String feedUrl);
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
