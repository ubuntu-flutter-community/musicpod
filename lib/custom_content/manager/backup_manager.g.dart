// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backup_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(BackupManager)
final backupManagerProvider = BackupManagerProvider._();

final class BackupManagerProvider
    extends $NotifierProvider<BackupManager, BackupState> {
  BackupManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'backupManagerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$backupManagerHash();

  @$internal
  @override
  BackupManager create() => BackupManager();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BackupState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BackupState>(value),
    );
  }
}

String _$backupManagerHash() => r'347c7edf1bbad26e4cba64bf59a84a0b6f56e2bc';

abstract class _$BackupManager extends $Notifier<BackupState> {
  BackupState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<BackupState, BackupState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<BackupState, BackupState>,
              BackupState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
