// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'has_tracks_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(HasTracksManager)
final hasTracksManagerProvider = HasTracksManagerProvider._();

final class HasTracksManagerProvider
    extends $AsyncNotifierProvider<HasTracksManager, bool> {
  HasTracksManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hasTracksManagerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hasTracksManagerHash();

  @$internal
  @override
  HasTracksManager create() => HasTracksManager();
}

String _$hasTracksManagerHash() => r'ad7c70af1a76f60555cc4d4c007555f8050b11d0';

abstract class _$HasTracksManager extends $AsyncNotifier<bool> {
  FutureOr<bool> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<bool>, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<bool>, bool>,
              AsyncValue<bool>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
