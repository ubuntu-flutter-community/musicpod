// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'queue_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(QueueManager)
final queueManagerProvider = QueueManagerProvider._();

final class QueueManagerProvider
    extends $NotifierProvider<QueueManager, Queue> {
  QueueManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'queueManagerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$queueManagerHash();

  @$internal
  @override
  QueueManager create() => QueueManager();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Queue value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Queue>(value),
    );
  }
}

String _$queueManagerHash() => r'3ad3c95f2894b8ddc5d297c0e039afec98a92541';

abstract class _$QueueManager extends $Notifier<Queue> {
  Queue build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Queue, Queue>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Queue, Queue>,
              Queue,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
