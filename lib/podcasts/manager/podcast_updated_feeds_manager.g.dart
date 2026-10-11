// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'podcast_updated_feeds_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PodcastUpdatedFeedsManager)
final podcastUpdatedFeedsManagerProvider =
    PodcastUpdatedFeedsManagerProvider._();

final class PodcastUpdatedFeedsManagerProvider
    extends $AsyncNotifierProvider<PodcastUpdatedFeedsManager, Set<String>> {
  PodcastUpdatedFeedsManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'podcastUpdatedFeedsManagerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$podcastUpdatedFeedsManagerHash();

  @$internal
  @override
  PodcastUpdatedFeedsManager create() => PodcastUpdatedFeedsManager();
}

String _$podcastUpdatedFeedsManagerHash() =>
    r'8dba4b4def8b46944be6375ee6cefd387066cf7a';

abstract class _$PodcastUpdatedFeedsManager
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
