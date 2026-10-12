// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'episodes_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(EpisodesManager)
final episodesManagerProvider = EpisodesManagerFamily._();

final class EpisodesManagerProvider
    extends $AsyncNotifierProvider<EpisodesManager, EpisodesState> {
  EpisodesManagerProvider._({
    required EpisodesManagerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'episodesManagerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$episodesManagerHash();

  @override
  String toString() {
    return r'episodesManagerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  EpisodesManager create() => EpisodesManager();

  @override
  bool operator ==(Object other) {
    return other is EpisodesManagerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$episodesManagerHash() => r'15dc5070d57b61552ac2095174aaf477bc9e1d21';

final class EpisodesManagerFamily extends $Family
    with
        $ClassFamilyOverride<
          EpisodesManager,
          AsyncValue<EpisodesState>,
          EpisodesState,
          FutureOr<EpisodesState>,
          String
        > {
  EpisodesManagerFamily._()
    : super(
        retry: null,
        name: r'episodesManagerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  EpisodesManagerProvider call(String feedUrl) =>
      EpisodesManagerProvider._(argument: feedUrl, from: this);

  @override
  String toString() => r'episodesManagerProvider';
}

abstract class _$EpisodesManager extends $AsyncNotifier<EpisodesState> {
  late final _$args = ref.$arg as String;
  String get feedUrl => _$args;

  FutureOr<EpisodesState> build(String feedUrl);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<EpisodesState>, EpisodesState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<EpisodesState>, EpisodesState>,
              AsyncValue<EpisodesState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
