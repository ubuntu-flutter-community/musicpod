// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_color_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PlayerColorManager)
final playerColorManagerProvider = PlayerColorManagerProvider._();

final class PlayerColorManagerProvider
    extends $NotifierProvider<PlayerColorManager, Color?> {
  PlayerColorManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'playerColorManagerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$playerColorManagerHash();

  @$internal
  @override
  PlayerColorManager create() => PlayerColorManager();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Color? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Color?>(value),
    );
  }
}

String _$playerColorManagerHash() =>
    r'd60c32f132750d82b92cda8d325472b6ac2611e9';

abstract class _$PlayerColorManager extends $Notifier<Color?> {
  Color? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Color?, Color?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Color?, Color?>,
              Color?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
