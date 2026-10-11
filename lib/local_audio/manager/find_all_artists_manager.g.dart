// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'find_all_artists_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FindAllArtistsManager)
final findAllArtistsManagerProvider = FindAllArtistsManagerProvider._();

final class FindAllArtistsManagerProvider
    extends $AsyncNotifierProvider<FindAllArtistsManager, List<String>?> {
  FindAllArtistsManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'findAllArtistsManagerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$findAllArtistsManagerHash();

  @$internal
  @override
  FindAllArtistsManager create() => FindAllArtistsManager();
}

String _$findAllArtistsManagerHash() =>
    r'7ba860748f381b22c970de4c37cfe139b93e303e';

abstract class _$FindAllArtistsManager extends $AsyncNotifier<List<String>?> {
  FutureOr<List<String>?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<String>?>, List<String>?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<String>?>, List<String>?>,
              AsyncValue<List<String>?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
