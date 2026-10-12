// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'podcast_feeds_with_downloads_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PodcastFeedsWithDownloadsManager)
final podcastFeedsWithDownloadsManagerProvider =
    PodcastFeedsWithDownloadsManagerProvider._();

final class PodcastFeedsWithDownloadsManagerProvider
    extends
        $AsyncNotifierProvider<PodcastFeedsWithDownloadsManager, Set<String>> {
  PodcastFeedsWithDownloadsManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'podcastFeedsWithDownloadsManagerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$podcastFeedsWithDownloadsManagerHash();

  @$internal
  @override
  PodcastFeedsWithDownloadsManager create() =>
      PodcastFeedsWithDownloadsManager();
}

String _$podcastFeedsWithDownloadsManagerHash() =>
    r'4a73637b21412b628602adf52aa84d1bb7d353f7';

abstract class _$PodcastFeedsWithDownloadsManager
    extends $AsyncNotifier<Set<String>> {
  FutureOr<Set<String>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Set<String>>, Set<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Set<String>>, Set<String>>,
              AsyncValue<Set<String>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
