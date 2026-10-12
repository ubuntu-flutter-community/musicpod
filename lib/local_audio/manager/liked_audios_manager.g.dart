// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'liked_audios_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LikedAudiosManager)
final likedAudiosManagerProvider = LikedAudiosManagerProvider._();

final class LikedAudiosManagerProvider
    extends $AsyncNotifierProvider<LikedAudiosManager, List<Audio>?> {
  LikedAudiosManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'likedAudiosManagerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$likedAudiosManagerHash();

  @$internal
  @override
  LikedAudiosManager create() => LikedAudiosManager();
}

String _$likedAudiosManagerHash() =>
    r'c62c72dfb16f5c346654910ddda0c79783fbb434';

abstract class _$LikedAudiosManager extends $AsyncNotifier<List<Audio>?> {
  FutureOr<List<Audio>?> build();
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
    return element.handleCreate(ref, build);
  }
}
