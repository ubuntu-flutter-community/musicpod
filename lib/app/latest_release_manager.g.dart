// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'latest_release_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LatestReleaseManager)
final latestReleaseManagerProvider = LatestReleaseManagerProvider._();

final class LatestReleaseManagerProvider
    extends $AsyncNotifierProvider<LatestReleaseManager, LatestReleaseState> {
  LatestReleaseManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'latestReleaseManagerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$latestReleaseManagerHash();

  @$internal
  @override
  LatestReleaseManager create() => LatestReleaseManager();
}

String _$latestReleaseManagerHash() =>
    r'd97a13211436975b8453e22d5ba60e394565a35a';

abstract class _$LatestReleaseManager
    extends $AsyncNotifier<LatestReleaseState> {
  FutureOr<LatestReleaseState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<LatestReleaseState>, LatestReleaseState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<LatestReleaseState>, LatestReleaseState>,
              AsyncValue<LatestReleaseState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
