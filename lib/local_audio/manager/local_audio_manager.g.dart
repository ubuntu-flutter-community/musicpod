// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_audio_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LocalAudioManager)
final localAudioManagerProvider = LocalAudioManagerProvider._();

final class LocalAudioManagerProvider
    extends $AsyncNotifierProvider<LocalAudioManager, LocalAudioState> {
  LocalAudioManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localAudioManagerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localAudioManagerHash();

  @$internal
  @override
  LocalAudioManager create() => LocalAudioManager();
}

String _$localAudioManagerHash() => r'47dde646113df0b7b4bb7ff7d3e8ece8f8b705eb';

abstract class _$LocalAudioManager extends $AsyncNotifier<LocalAudioState> {
  FutureOr<LocalAudioState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<LocalAudioState>, LocalAudioState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<LocalAudioState>, LocalAudioState>,
              AsyncValue<LocalAudioState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
