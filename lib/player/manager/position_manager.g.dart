// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'position_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PositionManager)
final positionManagerProvider = PositionManagerProvider._();

final class PositionManagerProvider
    extends $NotifierProvider<PositionManager, Duration?> {
  PositionManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'positionManagerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$positionManagerHash();

  @$internal
  @override
  PositionManager create() => PositionManager();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Duration? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Duration?>(value),
    );
  }
}

String _$positionManagerHash() => r'23c6f4814ff3e2273e935b079dab76579c29256e';

abstract class _$PositionManager extends $Notifier<Duration?> {
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
