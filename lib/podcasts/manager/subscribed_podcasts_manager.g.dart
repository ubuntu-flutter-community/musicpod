// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscribed_podcasts_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SubscribedPodcastsManager)
final subscribedPodcastsManagerProvider = SubscribedPodcastsManagerProvider._();

final class SubscribedPodcastsManagerProvider
    extends $AsyncNotifierProvider<SubscribedPodcastsManager, Set<String>> {
  SubscribedPodcastsManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'subscribedPodcastsManagerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$subscribedPodcastsManagerHash();

  @$internal
  @override
  SubscribedPodcastsManager create() => SubscribedPodcastsManager();
}

String _$subscribedPodcastsManagerHash() =>
    r'44da23ef098210077aef21ef216263331046247a';

abstract class _$SubscribedPodcastsManager extends $AsyncNotifier<Set<String>> {
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
