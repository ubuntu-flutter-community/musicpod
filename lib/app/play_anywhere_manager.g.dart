// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'play_anywhere_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PlayAnywhereManager)
final playAnywhereManagerProvider = PlayAnywhereManagerProvider._();

final class PlayAnywhereManagerProvider
    extends
        $NotifierProvider<
          PlayAnywhereManager,
          AsyncValue<PlayAnywhereResult?>
        > {
  PlayAnywhereManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'playAnywhereManagerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$playAnywhereManagerHash();

  @$internal
  @override
  PlayAnywhereManager create() => PlayAnywhereManager();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<PlayAnywhereResult?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<PlayAnywhereResult?>>(
        value,
      ),
    );
  }
}

String _$playAnywhereManagerHash() =>
    r'2a908ac2007c60e7f19f2bf6d8942cb54dca897f';

abstract class _$PlayAnywhereManager
    extends $Notifier<AsyncValue<PlayAnywhereResult?>> {
  AsyncValue<PlayAnywhereResult?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<PlayAnywhereResult?>,
              AsyncValue<PlayAnywhereResult?>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<PlayAnywhereResult?>,
                AsyncValue<PlayAnywhereResult?>
              >,
              AsyncValue<PlayAnywhereResult?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
