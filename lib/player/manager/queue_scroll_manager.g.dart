// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'queue_scroll_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(QueueScrollManager)
final queueScrollManagerProvider = QueueScrollManagerProvider._();

final class QueueScrollManagerProvider
    extends $NotifierProvider<QueueScrollManager, QueueScrollState> {
  QueueScrollManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'queueScrollManagerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$queueScrollManagerHash();

  @$internal
  @override
  QueueScrollManager create() => QueueScrollManager();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(QueueScrollState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<QueueScrollState>(value),
    );
  }
}

String _$queueScrollManagerHash() =>
    r'03f04d623475de5d121b0a425ea64b45d9740d5c';

abstract class _$QueueScrollManager extends $Notifier<QueueScrollState> {
  QueueScrollState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<QueueScrollState, QueueScrollState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<QueueScrollState, QueueScrollState>,
              QueueScrollState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
