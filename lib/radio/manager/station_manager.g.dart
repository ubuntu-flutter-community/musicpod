// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'station_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(StationManager)
final stationManagerProvider = StationManagerFamily._();

final class StationManagerProvider
    extends $AsyncNotifierProvider<StationManager, Audio?> {
  StationManagerProvider._({
    required StationManagerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'stationManagerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$stationManagerHash();

  @override
  String toString() {
    return r'stationManagerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  StationManager create() => StationManager();

  @override
  bool operator ==(Object other) {
    return other is StationManagerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$stationManagerHash() => r'10f23f0c0d36744570b4649954397518f7a9a5d9';

final class StationManagerFamily extends $Family
    with
        $ClassFamilyOverride<
          StationManager,
          AsyncValue<Audio?>,
          Audio?,
          FutureOr<Audio?>,
          String
        > {
  StationManagerFamily._()
    : super(
        retry: null,
        name: r'stationManagerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  StationManagerProvider call(String uuid) =>
      StationManagerProvider._(argument: uuid, from: this);

  @override
  String toString() => r'stationManagerProvider';
}

abstract class _$StationManager extends $AsyncNotifier<Audio?> {
  late final _$args = ref.$arg as String;
  String get uuid => _$args;

  FutureOr<Audio?> build(String uuid);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Audio?>, Audio?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Audio?>, Audio?>,
              AsyncValue<Audio?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(StationNameManager)
final stationNameManagerProvider = StationNameManagerFamily._();

final class StationNameManagerProvider
    extends $AsyncNotifierProvider<StationNameManager, String?> {
  StationNameManagerProvider._({
    required StationNameManagerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'stationNameManagerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$stationNameManagerHash();

  @override
  String toString() {
    return r'stationNameManagerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  StationNameManager create() => StationNameManager();

  @override
  bool operator ==(Object other) {
    return other is StationNameManagerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$stationNameManagerHash() =>
    r'705ca676bec4800a21d1178ace0ec01337e94bd0';

final class StationNameManagerFamily extends $Family
    with
        $ClassFamilyOverride<
          StationNameManager,
          AsyncValue<String?>,
          String?,
          FutureOr<String?>,
          String
        > {
  StationNameManagerFamily._()
    : super(
        retry: null,
        name: r'stationNameManagerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  StationNameManagerProvider call(String uuid) =>
      StationNameManagerProvider._(argument: uuid, from: this);

  @override
  String toString() => r'stationNameManagerProvider';
}

abstract class _$StationNameManager extends $AsyncNotifier<String?> {
  late final _$args = ref.$arg as String;
  String get uuid => _$args;

  FutureOr<String?> build(String uuid);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<String?>, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<String?>, String?>,
              AsyncValue<String?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(StationImageManager)
final stationImageManagerProvider = StationImageManagerFamily._();

final class StationImageManagerProvider
    extends $AsyncNotifierProvider<StationImageManager, String?> {
  StationImageManagerProvider._({
    required StationImageManagerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'stationImageManagerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$stationImageManagerHash();

  @override
  String toString() {
    return r'stationImageManagerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  StationImageManager create() => StationImageManager();

  @override
  bool operator ==(Object other) {
    return other is StationImageManagerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$stationImageManagerHash() =>
    r'78a129b88feb0a0761ceefd3cd16407957000765';

final class StationImageManagerFamily extends $Family
    with
        $ClassFamilyOverride<
          StationImageManager,
          AsyncValue<String?>,
          String?,
          FutureOr<String?>,
          String
        > {
  StationImageManagerFamily._()
    : super(
        retry: null,
        name: r'stationImageManagerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  StationImageManagerProvider call(String uuid) =>
      StationImageManagerProvider._(argument: uuid, from: this);

  @override
  String toString() => r'stationImageManagerProvider';
}

abstract class _$StationImageManager extends $AsyncNotifier<String?> {
  late final _$args = ref.$arg as String;
  String get uuid => _$args;

  FutureOr<String?> build(String uuid);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<String?>, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<String?>, String?>,
              AsyncValue<String?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
