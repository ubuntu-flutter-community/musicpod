// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routing_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(RoutingManager)
final routingManagerProvider = RoutingManagerProvider._();

final class RoutingManagerProvider
    extends $NotifierProvider<RoutingManager, String> {
  RoutingManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'routingManagerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$routingManagerHash();

  @$internal
  @override
  RoutingManager create() => RoutingManager();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$routingManagerHash() => r'035a9f17d62f696020a24eee6d6d4b75c777d75e';

abstract class _$RoutingManager extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
