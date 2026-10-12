// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'change_local_meta_data_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ChangeLocalMetaDataManager)
final changeLocalMetaDataManagerProvider = ChangeLocalMetaDataManagerFamily._();

final class ChangeLocalMetaDataManagerProvider
    extends
        $NotifierProvider<
          ChangeLocalMetaDataManager,
          ChangeLocalMetaDataState
        > {
  ChangeLocalMetaDataManagerProvider._({
    required ChangeLocalMetaDataManagerFamily super.from,
    required Audio super.argument,
  }) : super(
         retry: null,
         name: r'changeLocalMetaDataManagerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$changeLocalMetaDataManagerHash();

  @override
  String toString() {
    return r'changeLocalMetaDataManagerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ChangeLocalMetaDataManager create() => ChangeLocalMetaDataManager();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChangeLocalMetaDataState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChangeLocalMetaDataState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ChangeLocalMetaDataManagerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$changeLocalMetaDataManagerHash() =>
    r'9bd4904dbb9641821fe5a5ca1f0d6393aee30fa4';

final class ChangeLocalMetaDataManagerFamily extends $Family
    with
        $ClassFamilyOverride<
          ChangeLocalMetaDataManager,
          ChangeLocalMetaDataState,
          ChangeLocalMetaDataState,
          ChangeLocalMetaDataState,
          Audio
        > {
  ChangeLocalMetaDataManagerFamily._()
    : super(
        retry: null,
        name: r'changeLocalMetaDataManagerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ChangeLocalMetaDataManagerProvider call(Audio audio) =>
      ChangeLocalMetaDataManagerProvider._(argument: audio, from: this);

  @override
  String toString() => r'changeLocalMetaDataManagerProvider';
}

abstract class _$ChangeLocalMetaDataManager
    extends $Notifier<ChangeLocalMetaDataState> {
  late final _$args = ref.$arg as Audio;
  Audio get audio => _$args;

  ChangeLocalMetaDataState build(Audio audio);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<ChangeLocalMetaDataState, ChangeLocalMetaDataState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ChangeLocalMetaDataState, ChangeLocalMetaDataState>,
              ChangeLocalMetaDataState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
