// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'radio_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(RadioManager)
final radioManagerProvider = RadioManagerProvider._();

final class RadioManagerProvider
    extends $AsyncNotifierProvider<RadioManager, String?> {
  RadioManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'radioManagerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$radioManagerHash();

  @$internal
  @override
  RadioManager create() => RadioManager();
}

String _$radioManagerHash() => r'a67f35f144352bf622cc8f0949cd46f90cddd663';

abstract class _$RadioManager extends $AsyncNotifier<String?> {
  FutureOr<String?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<String?>, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<String?>, String?>,
              AsyncValue<String?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(SimilarStationManager)
final similarStationManagerProvider = SimilarStationManagerProvider._();

final class SimilarStationManagerProvider
    extends $AsyncNotifierProvider<SimilarStationManager, Audio?> {
  SimilarStationManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'similarStationManagerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$similarStationManagerHash();

  @$internal
  @override
  SimilarStationManager create() => SimilarStationManager();
}

String _$similarStationManagerHash() =>
    r'9269bdfceded311c5c12c72011aff9a3e28985e6';

abstract class _$SimilarStationManager extends $AsyncNotifier<Audio?> {
  FutureOr<Audio?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Audio?>, Audio?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Audio?>, Audio?>,
              AsyncValue<Audio?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
