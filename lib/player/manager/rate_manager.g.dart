// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rate_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(RateManager)
final rateManagerProvider = RateManagerProvider._();

final class RateManagerProvider extends $NotifierProvider<RateManager, double> {
  RateManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rateManagerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rateManagerHash();

  @$internal
  @override
  RateManager create() => RateManager();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }
}

String _$rateManagerHash() => r'a62ea5f52c627f116b0b9f471c1f564cf7304f67';

abstract class _$RateManager extends $Notifier<double> {
  double build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<double, double>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<double, double>,
              double,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
