// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'find_album_name_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FindAlbumNameManager)
final findAlbumNameManagerProvider = FindAlbumNameManagerFamily._();

final class FindAlbumNameManagerProvider
    extends $AsyncNotifierProvider<FindAlbumNameManager, String?> {
  FindAlbumNameManagerProvider._({
    required FindAlbumNameManagerFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'findAlbumNameManagerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$findAlbumNameManagerHash();

  @override
  String toString() {
    return r'findAlbumNameManagerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  FindAlbumNameManager create() => FindAlbumNameManager();

  @override
  bool operator ==(Object other) {
    return other is FindAlbumNameManagerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$findAlbumNameManagerHash() =>
    r'7e5627dfb5ae52d4296d7ba1ead8a47b8b8f7bf6';

final class FindAlbumNameManagerFamily extends $Family
    with
        $ClassFamilyOverride<
          FindAlbumNameManager,
          AsyncValue<String?>,
          String?,
          FutureOr<String?>,
          int
        > {
  FindAlbumNameManagerFamily._()
    : super(
        retry: null,
        name: r'findAlbumNameManagerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FindAlbumNameManagerProvider call(int albumId) =>
      FindAlbumNameManagerProvider._(argument: albumId, from: this);

  @override
  String toString() => r'findAlbumNameManagerProvider';
}

abstract class _$FindAlbumNameManager extends $AsyncNotifier<String?> {
  late final _$args = ref.$arg as int;
  int get albumId => _$args;

  FutureOr<String?> build(int albumId);
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
