// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'find_all_genres_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FindAllGenresManager)
final findAllGenresManagerProvider = FindAllGenresManagerProvider._();

final class FindAllGenresManagerProvider
    extends $AsyncNotifierProvider<FindAllGenresManager, List<String>?> {
  FindAllGenresManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'findAllGenresManagerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$findAllGenresManagerHash();

  @$internal
  @override
  FindAllGenresManager create() => FindAllGenresManager();
}

String _$findAllGenresManagerHash() =>
    r'c00c9f4c99503f167614042b04dfe2be0f29d92d';

abstract class _$FindAllGenresManager extends $AsyncNotifier<List<String>?> {
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
