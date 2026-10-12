// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'podcast_short_info_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PodcastShortInfoManager)
final podcastShortInfoManagerProvider = PodcastShortInfoManagerFamily._();

final class PodcastShortInfoManagerProvider
    extends $AsyncNotifierProvider<PodcastShortInfoManager, PodcastShortInfo?> {
  PodcastShortInfoManagerProvider._({
    required PodcastShortInfoManagerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'podcastShortInfoManagerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$podcastShortInfoManagerHash();

  @override
  String toString() {
    return r'podcastShortInfoManagerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  PodcastShortInfoManager create() => PodcastShortInfoManager();

  @override
  bool operator ==(Object other) {
    return other is PodcastShortInfoManagerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$podcastShortInfoManagerHash() =>
    r'0f98250d3bd679f6278d81edd1543676a5cb22c0';

final class PodcastShortInfoManagerFamily extends $Family
    with
        $ClassFamilyOverride<
          PodcastShortInfoManager,
          AsyncValue<PodcastShortInfo?>,
          PodcastShortInfo?,
          FutureOr<PodcastShortInfo?>,
          String
        > {
  PodcastShortInfoManagerFamily._()
    : super(
        retry: null,
        name: r'podcastShortInfoManagerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PodcastShortInfoManagerProvider call(String feedUrl) =>
      PodcastShortInfoManagerProvider._(argument: feedUrl, from: this);

  @override
  String toString() => r'podcastShortInfoManagerProvider';
}

abstract class _$PodcastShortInfoManager
    extends $AsyncNotifier<PodcastShortInfo?> {
  late final _$args = ref.$arg as String;
  String get feedUrl => _$args;

  FutureOr<PodcastShortInfo?> build(String feedUrl);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<PodcastShortInfo?>, PodcastShortInfo?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<PodcastShortInfo?>, PodcastShortInfo?>,
              AsyncValue<PodcastShortInfo?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
