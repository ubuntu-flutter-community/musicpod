// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_cover_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LocalCoverManager)
final localCoverManagerProvider = LocalCoverManagerFamily._();

final class LocalCoverManagerProvider
    extends $AsyncNotifierProvider<LocalCoverManager, Uint8List?> {
  LocalCoverManagerProvider._({
    required LocalCoverManagerFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'localCoverManagerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$localCoverManagerHash();

  @override
  String toString() {
    return r'localCoverManagerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  LocalCoverManager create() => LocalCoverManager();

  @override
  bool operator ==(Object other) {
    return other is LocalCoverManagerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$localCoverManagerHash() => r'e91f234a147e27e3b2a7dae0784e0018e5831cf8';

final class LocalCoverManagerFamily extends $Family
    with
        $ClassFamilyOverride<
          LocalCoverManager,
          AsyncValue<Uint8List?>,
          Uint8List?,
          FutureOr<Uint8List?>,
          int
        > {
  LocalCoverManagerFamily._()
    : super(
        retry: null,
        name: r'localCoverManagerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  LocalCoverManagerProvider call(int albumId) =>
      LocalCoverManagerProvider._(argument: albumId, from: this);

  @override
  String toString() => r'localCoverManagerProvider';
}

abstract class _$LocalCoverManager extends $AsyncNotifier<Uint8List?> {
  late final _$args = ref.$arg as int;
  int get albumId => _$args;

  FutureOr<Uint8List?> build(int albumId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Uint8List?>, Uint8List?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Uint8List?>, Uint8List?>,
              AsyncValue<Uint8List?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
