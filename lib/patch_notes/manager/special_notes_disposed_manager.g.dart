// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'special_notes_disposed_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SpecialNotesDisposedManager)
final specialNotesDisposedManagerProvider =
    SpecialNotesDisposedManagerProvider._();

final class SpecialNotesDisposedManagerProvider
    extends $NotifierProvider<SpecialNotesDisposedManager, bool> {
  SpecialNotesDisposedManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'specialNotesDisposedManagerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$specialNotesDisposedManagerHash();

  @$internal
  @override
  SpecialNotesDisposedManager create() => SpecialNotesDisposedManager();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$specialNotesDisposedManagerHash() =>
    r'1cedd5a65191be530de45ca1721d20ee0642d1b7';

abstract class _$SpecialNotesDisposedManager extends $Notifier<bool> {
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
