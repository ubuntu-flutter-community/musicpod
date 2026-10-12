// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recent_patch_notes_disposed_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(RecentPatchNotesDisposedManager)
final recentPatchNotesDisposedManagerProvider =
    RecentPatchNotesDisposedManagerProvider._();

final class RecentPatchNotesDisposedManagerProvider
    extends $NotifierProvider<RecentPatchNotesDisposedManager, bool> {
  RecentPatchNotesDisposedManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recentPatchNotesDisposedManagerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recentPatchNotesDisposedManagerHash();

  @$internal
  @override
  RecentPatchNotesDisposedManager create() => RecentPatchNotesDisposedManager();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$recentPatchNotesDisposedManagerHash() =>
    r'4cf0fdd8e805be9a373ef1b6fc56f6c7113fabc5';

abstract class _$RecentPatchNotesDisposedManager extends $Notifier<bool> {
  bool build();
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
    return element.handleCreate(ref, build);
  }
}
