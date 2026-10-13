// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'online_art_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(OnlineArtManager)
final onlineArtManagerProvider = OnlineArtManagerFamily._();

final class OnlineArtManagerProvider
    extends $AsyncNotifierProvider<OnlineArtManager, String?> {
  OnlineArtManagerProvider._({
    required OnlineArtManagerFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'onlineArtManagerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$onlineArtManagerHash();

  @override
  String toString() {
    return r'onlineArtManagerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  OnlineArtManager create() => OnlineArtManager();

  @override
  bool operator ==(Object other) {
    return other is OnlineArtManagerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$onlineArtManagerHash() => r'f73a9e651115d9fd6bcf326d21e81e90110d006d';

final class OnlineArtManagerFamily extends $Family
    with
        $ClassFamilyOverride<
          OnlineArtManager,
          AsyncValue<String?>,
          String?,
          FutureOr<String?>,
          String?
        > {
  OnlineArtManagerFamily._()
    : super(
        retry: null,
        name: r'onlineArtManagerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  OnlineArtManagerProvider call(String? icyTitle) =>
      OnlineArtManagerProvider._(argument: icyTitle, from: this);

  @override
  String toString() => r'onlineArtManagerProvider';
}

abstract class _$OnlineArtManager extends $AsyncNotifier<String?> {
  late final _$args = ref.$arg as String?;
  String? get icyTitle => _$args;

  FutureOr<String?> build(String? icyTitle);
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
