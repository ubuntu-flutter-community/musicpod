// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blocked_icy_titles_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(BlockedIcyTitlesManager)
final blockedIcyTitlesManagerProvider = BlockedIcyTitlesManagerProvider._();

final class BlockedIcyTitlesManagerProvider
    extends $NotifierProvider<BlockedIcyTitlesManager, Set<String>> {
  BlockedIcyTitlesManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'blockedIcyTitlesManagerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$blockedIcyTitlesManagerHash();

  @$internal
  @override
  BlockedIcyTitlesManager create() => BlockedIcyTitlesManager();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<String>>(value),
    );
  }
}

String _$blockedIcyTitlesManagerHash() =>
    r'04224dbd42347b195971af6202aaeffd7e080639';

abstract class _$BlockedIcyTitlesManager extends $Notifier<Set<String>> {
  Set<String> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Set<String>, Set<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Set<String>, Set<String>>,
              Set<String>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
