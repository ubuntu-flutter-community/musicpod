// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lyrics_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LyricsManager)
final lyricsManagerProvider = LyricsManagerFamily._();

final class LyricsManagerProvider
    extends $AsyncNotifierProvider<LyricsManager, LyricsAndArtResult?> {
  LyricsManagerProvider._({
    required LyricsManagerFamily super.from,
    required LyricsAndArtParam super.argument,
  }) : super(
         retry: null,
         name: r'lyricsManagerProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$lyricsManagerHash();

  @override
  String toString() {
    return r'lyricsManagerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  LyricsManager create() => LyricsManager();

  @override
  bool operator ==(Object other) {
    return other is LyricsManagerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$lyricsManagerHash() => r'1d418370f333495a6d044c185d6bf7ecb61b2a9b';

final class LyricsManagerFamily extends $Family
    with
        $ClassFamilyOverride<
          LyricsManager,
          AsyncValue<LyricsAndArtResult?>,
          LyricsAndArtResult?,
          FutureOr<LyricsAndArtResult?>,
          LyricsAndArtParam
        > {
  LyricsManagerFamily._()
    : super(
        retry: null,
        name: r'lyricsManagerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  LyricsManagerProvider call(LyricsAndArtParam param) =>
      LyricsManagerProvider._(argument: param, from: this);

  @override
  String toString() => r'lyricsManagerProvider';
}

abstract class _$LyricsManager extends $AsyncNotifier<LyricsAndArtResult?> {
  late final _$args = ref.$arg as LyricsAndArtParam;
  LyricsAndArtParam get param => _$args;

  FutureOr<LyricsAndArtResult?> build(LyricsAndArtParam param);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<LyricsAndArtResult?>, LyricsAndArtResult?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<LyricsAndArtResult?>, LyricsAndArtResult?>,
              AsyncValue<LyricsAndArtResult?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
