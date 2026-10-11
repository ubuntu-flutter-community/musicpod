// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'click_station_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ClickStationManager)
final clickStationManagerProvider = ClickStationManagerProvider._();

final class ClickStationManagerProvider
    extends $NotifierProvider<ClickStationManager, void> {
  ClickStationManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clickStationManagerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clickStationManagerHash();

  @$internal
  @override
  ClickStationManager create() => ClickStationManager();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$clickStationManagerHash() =>
    r'261d3bd6db9fbf2c03a48784dc4e8176d8bbf89d';

abstract class _$ClickStationManager extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
