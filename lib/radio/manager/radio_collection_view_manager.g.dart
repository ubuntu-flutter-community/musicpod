// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'radio_collection_view_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(RadioCollectionViewManager)
final radioCollectionViewManagerProvider =
    RadioCollectionViewManagerProvider._();

final class RadioCollectionViewManagerProvider
    extends $NotifierProvider<RadioCollectionViewManager, RadioCollectionView> {
  RadioCollectionViewManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'radioCollectionViewManagerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$radioCollectionViewManagerHash();

  @$internal
  @override
  RadioCollectionViewManager create() => RadioCollectionViewManager();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RadioCollectionView value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RadioCollectionView>(value),
    );
  }
}

String _$radioCollectionViewManagerHash() =>
    r'eeadbcddd53c565a82ba27217f6bab9fa7c69b12';

abstract class _$RadioCollectionViewManager
    extends $Notifier<RadioCollectionView> {
  RadioCollectionView build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<RadioCollectionView, RadioCollectionView>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<RadioCollectionView, RadioCollectionView>,
              RadioCollectionView,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
