// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'full_window_mode_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FullWindowModeManager)
final fullWindowModeManagerProvider = FullWindowModeManagerProvider._();

final class FullWindowModeManagerProvider
    extends $NotifierProvider<FullWindowModeManager, bool> {
  FullWindowModeManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'fullWindowModeManagerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$fullWindowModeManagerHash();

  @$internal
  @override
  FullWindowModeManager create() => FullWindowModeManager();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$fullWindowModeManagerHash() =>
    r'3051950bbbd815ade18d65b884dd6f4b1abd407a';

abstract class _$FullWindowModeManager extends $Notifier<bool> {
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
