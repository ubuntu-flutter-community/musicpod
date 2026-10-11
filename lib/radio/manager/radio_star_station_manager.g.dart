// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'radio_star_station_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(RadioStarStationManager)
final radioStarStationManagerProvider = RadioStarStationManagerProvider._();

final class RadioStarStationManagerProvider
    extends $AsyncNotifierProvider<RadioStarStationManager, Set<String>> {
  RadioStarStationManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'radioStarStationManagerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$radioStarStationManagerHash();

  @$internal
  @override
  RadioStarStationManager create() => RadioStarStationManager();
}

String _$radioStarStationManagerHash() =>
    r'831b923d7e8bc5bbb8aeedf31d183a95d7f18730';

abstract class _$RadioStarStationManager extends $AsyncNotifier<Set<String>> {
  FutureOr<Set<String>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Set<String>>, Set<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Set<String>>, Set<String>>,
              AsyncValue<Set<String>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
