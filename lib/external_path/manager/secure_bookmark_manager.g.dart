// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'secure_bookmark_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SecureBookmarkManager)
final secureBookmarkManagerProvider = SecureBookmarkManagerProvider._();

final class SecureBookmarkManagerProvider
    extends $NotifierProvider<SecureBookmarkManager, bool> {
  SecureBookmarkManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'secureBookmarkManagerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$secureBookmarkManagerHash();

  @$internal
  @override
  SecureBookmarkManager create() => SecureBookmarkManager();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$secureBookmarkManagerHash() =>
    r'a6a04f83ca0b65f7afd32d8ac4240ac089eb676c';

abstract class _$SecureBookmarkManager extends $Notifier<bool> {
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
