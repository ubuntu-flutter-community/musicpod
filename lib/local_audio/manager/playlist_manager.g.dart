// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playlist_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PlaylistManager)
final playlistManagerProvider = PlaylistManagerFamily._();

final class PlaylistManagerProvider
    extends $AsyncNotifierProvider<PlaylistManager, List<Audio>?> {
  PlaylistManagerProvider._({
    required PlaylistManagerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'playlistManagerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$playlistManagerHash();

  @override
  String toString() {
    return r'playlistManagerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  PlaylistManager create() => PlaylistManager();

  @override
  bool operator ==(Object other) {
    return other is PlaylistManagerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$playlistManagerHash() => r'a8b8c25907aea6822a17e6967247a07dc2eabbd0';

final class PlaylistManagerFamily extends $Family
    with
        $ClassFamilyOverride<
          PlaylistManager,
          AsyncValue<List<Audio>?>,
          List<Audio>?,
          FutureOr<List<Audio>?>,
          String
        > {
  PlaylistManagerFamily._()
    : super(
        retry: null,
        name: r'playlistManagerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PlaylistManagerProvider call(String playlistId) =>
      PlaylistManagerProvider._(argument: playlistId, from: this);

  @override
  String toString() => r'playlistManagerProvider';
}

abstract class _$PlaylistManager extends $AsyncNotifier<List<Audio>?> {
  late final _$args = ref.$arg as String;
  String get playlistId => _$args;

  FutureOr<List<Audio>?> build(String playlistId);
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
    return element.handleCreate(ref, () => build(_$args));
  }
}
