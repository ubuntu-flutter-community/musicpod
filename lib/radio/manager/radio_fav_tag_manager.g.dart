// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'radio_fav_tag_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(RadioFavTagManager)
final radioFavTagManagerProvider = RadioFavTagManagerProvider._();

final class RadioFavTagManagerProvider
    extends $AsyncNotifierProvider<RadioFavTagManager, Set<String>> {
  RadioFavTagManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'radioFavTagManagerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$radioFavTagManagerHash();

  @$internal
  @override
  RadioFavTagManager create() => RadioFavTagManager();
}

String _$radioFavTagManagerHash() =>
    r'08eee4e6223ce9c60169266aa871c51923ac7d67';

abstract class _$RadioFavTagManager extends $AsyncNotifier<Set<String>> {
  FutureOr<Set<String>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Set<String>>, Set<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Set<String>>, Set<String>>,
              AsyncValue<Set<String>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
