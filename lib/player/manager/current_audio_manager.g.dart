// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'current_audio_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CurrentAudioManager)
final currentAudioManagerProvider = CurrentAudioManagerProvider._();

final class CurrentAudioManagerProvider
    extends $NotifierProvider<CurrentAudioManager, Audio?> {
  CurrentAudioManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentAudioManagerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentAudioManagerHash();

  @$internal
  @override
  CurrentAudioManager create() => CurrentAudioManager();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Audio? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Audio?>(value),
    );
  }
}

String _$currentAudioManagerHash() =>
    r'172222ce316555a41ea422a1984f2590b774fed3';

abstract class _$CurrentAudioManager extends $Notifier<Audio?> {
  Audio? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Audio?, Audio?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Audio?, Audio?>,
              Audio?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
