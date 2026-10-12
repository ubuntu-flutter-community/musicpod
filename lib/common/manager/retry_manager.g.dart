// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'retry_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(RetryManager)
final retryManagerProvider = RetryManagerFamily._();

final class RetryManagerProvider extends $NotifierProvider<RetryManager, int> {
  RetryManagerProvider._({
    required RetryManagerFamily super.from,
    required RetryCapsule super.argument,
  }) : super(
         retry: null,
         name: r'retryManagerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$retryManagerHash();

  @override
  String toString() {
    return r'retryManagerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  RetryManager create() => RetryManager();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is RetryManagerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$retryManagerHash() => r'81e4cc53c9f2846f76f3073f872ec72d05b27cff';

final class RetryManagerFamily extends $Family
    with $ClassFamilyOverride<RetryManager, int, int, int, RetryCapsule> {
  RetryManagerFamily._()
    : super(
        retry: null,
        name: r'retryManagerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  RetryManagerProvider call(RetryCapsule capsule) =>
      RetryManagerProvider._(argument: capsule, from: this);

  @override
  String toString() => r'retryManagerProvider';
}

abstract class _$RetryManager extends $Notifier<int> {
  late final _$args = ref.$arg as RetryCapsule;
  RetryCapsule get capsule => _$args;

  int build(RetryCapsule capsule);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
