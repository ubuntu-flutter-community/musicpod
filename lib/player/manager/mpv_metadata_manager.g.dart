// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mpv_metadata_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MpvMetadataManager)
final mpvMetadataManagerProvider = MpvMetadataManagerProvider._();

final class MpvMetadataManagerProvider
    extends $NotifierProvider<MpvMetadataManager, MpvMetaData?> {
  MpvMetadataManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mpvMetadataManagerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mpvMetadataManagerHash();

  @$internal
  @override
  MpvMetadataManager create() => MpvMetadataManager();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MpvMetaData? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MpvMetaData?>(value),
    );
  }
}

String _$mpvMetadataManagerHash() =>
    r'e9ccfdc653b15efafc7eeacb5b067f5f00f34041';

abstract class _$MpvMetadataManager extends $Notifier<MpvMetaData?> {
  MpvMetaData? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<MpvMetaData?, MpvMetaData?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MpvMetaData?, MpvMetaData?>,
              MpvMetaData?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
