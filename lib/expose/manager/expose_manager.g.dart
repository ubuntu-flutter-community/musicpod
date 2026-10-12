// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expose_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ExposeManager)
final exposeManagerProvider = ExposeManagerProvider._();

final class ExposeManagerProvider
    extends $NotifierProvider<ExposeManager, bool> {
  ExposeManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exposeManagerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exposeManagerHash();

  @$internal
  @override
  ExposeManager create() => ExposeManager();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$exposeManagerHash() => r'b2f960727cb15c6901b7bbd16affc6a1f35ce059';

abstract class _$ExposeManager extends $Notifier<bool> {
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
