// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wipe_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(WipeManager)
final wipeManagerProvider = WipeManagerProvider._();

final class WipeManagerProvider
    extends $AsyncNotifierProvider<WipeManager, void> {
  WipeManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'wipeManagerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$wipeManagerHash();

  @$internal
  @override
  WipeManager create() => WipeManager();
}

String _$wipeManagerHash() => r'abb718689a206b6af0acd79cf93f6d61f8eab11c';

abstract class _$WipeManager extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
