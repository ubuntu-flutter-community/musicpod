// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'podcast_load_genres_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PodcastLoadGenresManager)
final podcastLoadGenresManagerProvider = PodcastLoadGenresManagerProvider._();

final class PodcastLoadGenresManagerProvider
    extends
        $AsyncNotifierProvider<PodcastLoadGenresManager, List<PodcastGenre>> {
  PodcastLoadGenresManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'podcastLoadGenresManagerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$podcastLoadGenresManagerHash();

  @$internal
  @override
  PodcastLoadGenresManager create() => PodcastLoadGenresManager();
}

String _$podcastLoadGenresManagerHash() =>
    r'fd11439f2aac88bf0427bf85eadc82faa2a06077';

abstract class _$PodcastLoadGenresManager
    extends $AsyncNotifier<List<PodcastGenre>> {
  FutureOr<List<PodcastGenre>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<PodcastGenre>>, List<PodcastGenre>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<PodcastGenre>>, List<PodcastGenre>>,
              AsyncValue<List<PodcastGenre>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
