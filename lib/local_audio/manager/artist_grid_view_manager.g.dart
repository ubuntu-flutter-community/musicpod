// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'artist_grid_view_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ArtistGridViewManager)
final artistGridViewManagerProvider = ArtistGridViewManagerFamily._();

final class ArtistGridViewManagerProvider
    extends $NotifierProvider<ArtistGridViewManager, bool> {
  ArtistGridViewManagerProvider._({
    required ArtistGridViewManagerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'artistGridViewManagerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$artistGridViewManagerHash();

  @override
  String toString() {
    return r'artistGridViewManagerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ArtistGridViewManager create() => ArtistGridViewManager();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ArtistGridViewManagerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$artistGridViewManagerHash() =>
    r'595afdaee8caf711b5e92494670974dcfa3694ae';

final class ArtistGridViewManagerFamily extends $Family
    with $ClassFamilyOverride<ArtistGridViewManager, bool, bool, bool, String> {
  ArtistGridViewManagerFamily._()
    : super(
        retry: null,
        name: r'artistGridViewManagerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ArtistGridViewManagerProvider call(String artist) =>
      ArtistGridViewManagerProvider._(argument: artist, from: this);

  @override
  String toString() => r'artistGridViewManagerProvider';
}

abstract class _$ArtistGridViewManager extends $Notifier<bool> {
  late final _$args = ref.$arg as String;
  String get artist => _$args;

  bool build(String artist);
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
    return element.handleCreate(ref, () => build(_$args));
  }
}
