// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'volume_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(VolumeManager)
final volumeManagerProvider = VolumeManagerProvider._();

final class VolumeManagerProvider
    extends $NotifierProvider<VolumeManager, double?> {
  VolumeManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'volumeManagerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$volumeManagerHash();

  @$internal
  @override
  VolumeManager create() => VolumeManager();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double?>(value),
    );
  }
}

String _$volumeManagerHash() => r'cca15b0eec347b658d9db6ad726da42a81fdb800';

abstract class _$VolumeManager extends $Notifier<double?> {
  double? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<double?, double?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<double?, double?>,
              double?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
