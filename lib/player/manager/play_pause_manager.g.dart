// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'play_pause_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PlayPauseManager)
final playPauseManagerProvider = PlayPauseManagerProvider._();

final class PlayPauseManagerProvider
    extends $NotifierProvider<PlayPauseManager, bool> {
  PlayPauseManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'playPauseManagerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$playPauseManagerHash();

  @$internal
  @override
  PlayPauseManager create() => PlayPauseManager();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$playPauseManagerHash() => r'e3b1d105e624215c3c7ab8944680c925b49acdf7';

abstract class _$PlayPauseManager extends $Notifier<bool> {
  bool build();
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
    return element.handleCreate(ref, build);
  }
}
