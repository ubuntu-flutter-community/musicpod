// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'buffer_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(BufferManager)
final bufferManagerProvider = BufferManagerProvider._();

final class BufferManagerProvider
    extends $NotifierProvider<BufferManager, Duration?> {
  BufferManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bufferManagerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bufferManagerHash();

  @$internal
  @override
  BufferManager create() => BufferManager();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Duration? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Duration?>(value),
    );
  }
}

String _$bufferManagerHash() => r'b27aa24efc2b91c994e0dfae9659ade2675af662';

abstract class _$BufferManager extends $Notifier<Duration?> {
  Duration? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Duration?, Duration?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Duration?, Duration?>,
              Duration?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
