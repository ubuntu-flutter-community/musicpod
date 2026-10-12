// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracks_synced_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TracksSyncedManager)
final tracksSyncedManagerProvider = TracksSyncedManagerProvider._();

final class TracksSyncedManagerProvider
    extends $AsyncNotifierProvider<TracksSyncedManager, bool> {
  TracksSyncedManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tracksSyncedManagerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tracksSyncedManagerHash();

  @$internal
  @override
  TracksSyncedManager create() => TracksSyncedManager();
}

String _$tracksSyncedManagerHash() =>
    r'faaecae7c2f3242f3928c138a8d7f308bd2054ae';

abstract class _$TracksSyncedManager extends $AsyncNotifier<bool> {
  FutureOr<bool> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<bool>, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<bool>, bool>,
              AsyncValue<bool>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
