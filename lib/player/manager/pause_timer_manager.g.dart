// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pause_timer_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PauseTimerManager)
final pauseTimerManagerProvider = PauseTimerManagerProvider._();

final class PauseTimerManagerProvider
    extends $NotifierProvider<PauseTimerManager, bool> {
  PauseTimerManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pauseTimerManagerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pauseTimerManagerHash();

  @$internal
  @override
  PauseTimerManager create() => PauseTimerManager();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$pauseTimerManagerHash() => r'394d3094bbd9ab2c5b8a630975074938bf3ae7a2';

abstract class _$PauseTimerManager extends $Notifier<bool> {
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
