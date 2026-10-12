// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'is_video_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(IsVideoManager)
final isVideoManagerProvider = IsVideoManagerProvider._();

final class IsVideoManagerProvider
    extends $NotifierProvider<IsVideoManager, bool> {
  IsVideoManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isVideoManagerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isVideoManagerHash();

  @$internal
  @override
  IsVideoManager create() => IsVideoManager();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isVideoManagerHash() => r'c06d163daeb7e48c7f30ffda939a47bec8c4518e';

abstract class _$IsVideoManager extends $Notifier<bool> {
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
