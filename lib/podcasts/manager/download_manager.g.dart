// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DownloadManager)
final downloadManagerProvider = DownloadManagerProvider._();

final class DownloadManagerProvider
    extends $AsyncNotifierProvider<DownloadManager, DownloadManagerState> {
  DownloadManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'downloadManagerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$downloadManagerHash();

  @$internal
  @override
  DownloadManager create() => DownloadManager();
}

String _$downloadManagerHash() => r'd1214b062e330c8916f5035038043f88fa26845d';

abstract class _$DownloadManager extends $AsyncNotifier<DownloadManagerState> {
  FutureOr<DownloadManagerState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<DownloadManagerState>, DownloadManagerState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<DownloadManagerState>,
                DownloadManagerState
              >,
              AsyncValue<DownloadManagerState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(PodcastEpisodeDownloadManager)
final podcastEpisodeDownloadManagerProvider =
    PodcastEpisodeDownloadManagerFamily._();

final class PodcastEpisodeDownloadManagerProvider
    extends
        $AsyncNotifierProvider<PodcastEpisodeDownloadManager, PodcastDownload> {
  PodcastEpisodeDownloadManagerProvider._({
    required PodcastEpisodeDownloadManagerFamily super.from,
    required Audio super.argument,
  }) : super(
         retry: null,
         name: r'podcastEpisodeDownloadManagerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$podcastEpisodeDownloadManagerHash();

  @override
  String toString() {
    return r'podcastEpisodeDownloadManagerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  PodcastEpisodeDownloadManager create() => PodcastEpisodeDownloadManager();

  @override
  bool operator ==(Object other) {
    return other is PodcastEpisodeDownloadManagerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$podcastEpisodeDownloadManagerHash() =>
    r'cfb497d7e8ea94627441e5be29ba4f2eaa4f8a03';

final class PodcastEpisodeDownloadManagerFamily extends $Family
    with
        $ClassFamilyOverride<
          PodcastEpisodeDownloadManager,
          AsyncValue<PodcastDownload>,
          PodcastDownload,
          FutureOr<PodcastDownload>,
          Audio
        > {
  PodcastEpisodeDownloadManagerFamily._()
    : super(
        retry: null,
        name: r'podcastEpisodeDownloadManagerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PodcastEpisodeDownloadManagerProvider call(Audio audio) =>
      PodcastEpisodeDownloadManagerProvider._(argument: audio, from: this);

  @override
  String toString() => r'podcastEpisodeDownloadManagerProvider';
}

abstract class _$PodcastEpisodeDownloadManager
    extends $AsyncNotifier<PodcastDownload> {
  late final _$args = ref.$arg as Audio;
  Audio get audio => _$args;

  FutureOr<PodcastDownload> build(Audio audio);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<PodcastDownload>, PodcastDownload>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<PodcastDownload>, PodcastDownload>,
              AsyncValue<PodcastDownload>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
