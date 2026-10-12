// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'show_playlist_add_audios_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ShowPlaylistAddAudiosManager)
final showPlaylistAddAudiosManagerProvider =
    ShowPlaylistAddAudiosManagerFamily._();

final class ShowPlaylistAddAudiosManagerProvider
    extends $NotifierProvider<ShowPlaylistAddAudiosManager, bool> {
  ShowPlaylistAddAudiosManagerProvider._({
    required ShowPlaylistAddAudiosManagerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'showPlaylistAddAudiosManagerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$showPlaylistAddAudiosManagerHash();

  @override
  String toString() {
    return r'showPlaylistAddAudiosManagerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ShowPlaylistAddAudiosManager create() => ShowPlaylistAddAudiosManager();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ShowPlaylistAddAudiosManagerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$showPlaylistAddAudiosManagerHash() =>
    r'cebd9fbaca66b9d0f700a25fafe4a97112be4dcc';

final class ShowPlaylistAddAudiosManagerFamily extends $Family
    with
        $ClassFamilyOverride<
          ShowPlaylistAddAudiosManager,
          bool,
          bool,
          bool,
          String
        > {
  ShowPlaylistAddAudiosManagerFamily._()
    : super(
        retry: null,
        name: r'showPlaylistAddAudiosManagerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ShowPlaylistAddAudiosManagerProvider call(String playlistId) =>
      ShowPlaylistAddAudiosManagerProvider._(argument: playlistId, from: this);

  @override
  String toString() => r'showPlaylistAddAudiosManagerProvider';
}

abstract class _$ShowPlaylistAddAudiosManager extends $Notifier<bool> {
  late final _$args = ref.$arg as String;
  String get playlistId => _$args;

  bool build(String playlistId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
