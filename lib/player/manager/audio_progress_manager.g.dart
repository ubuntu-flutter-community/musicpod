// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audio_progress_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AudioProgressManager)
final audioProgressManagerProvider = AudioProgressManagerProvider._();

final class AudioProgressManagerProvider
    extends $NotifierProvider<AudioProgressManager, AudioProgressState> {
  AudioProgressManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'audioProgressManagerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$audioProgressManagerHash();

  @$internal
  @override
  AudioProgressManager create() => AudioProgressManager();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AudioProgressState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AudioProgressState>(value),
    );
  }
}

String _$audioProgressManagerHash() =>
    r'3a9592c196b9b9b8e6669bec3c658a945e18f5a0';

abstract class _$AudioProgressManager extends $Notifier<AudioProgressState> {
  AudioProgressState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AudioProgressState, AudioProgressState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AudioProgressState, AudioProgressState>,
              AudioProgressState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
