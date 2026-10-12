// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shuffle_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ShuffleManager)
final shuffleManagerProvider = ShuffleManagerProvider._();

final class ShuffleManagerProvider
    extends $NotifierProvider<ShuffleManager, bool> {
  ShuffleManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'shuffleManagerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$shuffleManagerHash();

  @$internal
  @override
  ShuffleManager create() => ShuffleManager();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$shuffleManagerHash() => r'a405defdf4a8831e1c94ae204f885b6c4e7830d0';

abstract class _$ShuffleManager extends $Notifier<bool> {
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
