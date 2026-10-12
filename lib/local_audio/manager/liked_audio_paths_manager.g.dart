// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'liked_audio_paths_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LikedAudioPathsManager)
final likedAudioPathsManagerProvider = LikedAudioPathsManagerProvider._();

final class LikedAudioPathsManagerProvider
    extends $AsyncNotifierProvider<LikedAudioPathsManager, Set<String>> {
  LikedAudioPathsManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'likedAudioPathsManagerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$likedAudioPathsManagerHash();

  @$internal
  @override
  LikedAudioPathsManager create() => LikedAudioPathsManager();
}

String _$likedAudioPathsManagerHash() =>
    r'f0721fb27258a63dc1d67f0766d6fc8f4b3c8c5e';

abstract class _$LikedAudioPathsManager extends $AsyncNotifier<Set<String>> {
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
