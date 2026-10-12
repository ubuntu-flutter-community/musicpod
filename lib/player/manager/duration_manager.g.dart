// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'duration_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DurationManager)
final durationManagerProvider = DurationManagerProvider._();

final class DurationManagerProvider
    extends $NotifierProvider<DurationManager, Duration?> {
  DurationManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'durationManagerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$durationManagerHash();

  @$internal
  @override
  DurationManager create() => DurationManager();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Duration? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Duration?>(value),
    );
  }
}

String _$durationManagerHash() => r'083a1282ce5b9047875a227b5719f5be7dae55d3';

abstract class _$DurationManager extends $Notifier<Duration?> {
  Duration? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Duration?, Duration?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Duration?, Duration?>,
              Duration?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
