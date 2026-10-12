// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mpv_metadata_history_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MpvMetadataHistoryManager)
final mpvMetadataHistoryManagerProvider = MpvMetadataHistoryManagerProvider._();

final class MpvMetadataHistoryManagerProvider
    extends
        $NotifierProvider<MpvMetadataHistoryManager, Map<String, MpvMetaData>> {
  MpvMetadataHistoryManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mpvMetadataHistoryManagerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mpvMetadataHistoryManagerHash();

  @$internal
  @override
  MpvMetadataHistoryManager create() => MpvMetadataHistoryManager();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, MpvMetaData> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, MpvMetaData>>(value),
    );
  }
}

String _$mpvMetadataHistoryManagerHash() =>
    r'48dfc790fe50af212cb178bb6393c6cb0fc690e4';

abstract class _$MpvMetadataHistoryManager
    extends $Notifier<Map<String, MpvMetaData>> {
  Map<String, MpvMetaData> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<Map<String, MpvMetaData>, Map<String, MpvMetaData>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Map<String, MpvMetaData>, Map<String, MpvMetaData>>,
              Map<String, MpvMetaData>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
