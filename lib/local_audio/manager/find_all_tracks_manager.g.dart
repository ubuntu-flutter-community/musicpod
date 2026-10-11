// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'find_all_tracks_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FindAllTracksManager)
final findAllTracksManagerProvider = FindAllTracksManagerProvider._();

final class FindAllTracksManagerProvider
    extends $AsyncNotifierProvider<FindAllTracksManager, List<Audio>> {
  FindAllTracksManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'findAllTracksManagerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$findAllTracksManagerHash();

  @$internal
  @override
  FindAllTracksManager create() => FindAllTracksManager();
}

String _$findAllTracksManagerHash() =>
    r'11deada0311b3ba3b47a4e0099a98713983da723';

abstract class _$FindAllTracksManager extends $AsyncNotifier<List<Audio>> {
  FutureOr<List<Audio>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Audio>>, List<Audio>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Audio>>, List<Audio>>,
              AsyncValue<List<Audio>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
