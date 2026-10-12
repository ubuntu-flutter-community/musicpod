import 'package:flutter_it/flutter_it.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:musicpod/custom_content/manager/backup_manager.dart';
import 'package:musicpod/settings/data/shared_preferences_keys.dart';
import 'package:musicpod/settings/service/settings_service.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'backup_manager_test.mocks.dart';

@GenerateMocks([SettingsService])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;
  late MockSettingsService mockSettingsService;
  final packageInfo = PackageInfo(
    appName: 'Musicpod',
    packageName: 'com.example.musicpod',
    version: '2.0.0',
    buildNumber: '1',
  );

  setUp(() async {
    await GetIt.I.reset();
    mockSettingsService = MockSettingsService();

    di.registerSingleton<SettingsService>(mockSettingsService);
    di.registerSingleton<PackageInfo>(packageInfo);

    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  group('BackupState', () {
    test('initial values are all false and confirm is disabled', () {
      const state = BackupState();
      expect(state.localAudio, isFalse);
      expect(state.podcast, isFalse);
      expect(state.radio, isFalse);
      expect(state.confirmEnabled, isFalse);
    });

    test('confirmEnabled is true only when all three are true', () {
      expect(
        const BackupState(localAudio: true, podcast: true, radio: false)
            .confirmEnabled,
        isFalse,
      );
      expect(
        const BackupState(localAudio: true, podcast: true, radio: true)
            .confirmEnabled,
        isTrue,
      );
    });

    test('copyWith updates individual properties', () {
      const initial = BackupState();
      final updated = initial.copyWith(localAudio: true);
      expect(updated.localAudio, isTrue);
      expect(updated.podcast, isFalse);
      expect(updated.radio, isFalse);
    });
  });

  group('BackupManager', () {
    test('initial state matches BackupState defaults', () {
      final state = container.read(backupManagerProvider);
      expect(state, const BackupState());
      expect(state.confirmEnabled, isFalse);
    });

    test('setLocalAudio, setPodcast, setRadio update state correctly', () {
      final notifier = container.read(backupManagerProvider.notifier);

      notifier.setLocalAudio(true);
      expect(container.read(backupManagerProvider).localAudio, isTrue);
      expect(container.read(backupManagerProvider).confirmEnabled, isFalse);

      notifier.setPodcast(true);
      expect(container.read(backupManagerProvider).podcast, isTrue);
      expect(container.read(backupManagerProvider).confirmEnabled, isFalse);

      notifier.setRadio(true);
      expect(container.read(backupManagerProvider).radio, isTrue);
      expect(container.read(backupManagerProvider).confirmEnabled, isTrue);
    });

    test('reset clears all selections back to false', () {
      final notifier = container.read(backupManagerProvider.notifier);
      notifier.setLocalAudio(true);
      notifier.setPodcast(true);
      notifier.setRadio(true);
      expect(container.read(backupManagerProvider).confirmEnabled, isTrue);

      notifier.reset();
      expect(container.read(backupManagerProvider), const BackupState());
      expect(container.read(backupManagerProvider).confirmEnabled, isFalse);
    });

    test('setBackupSaved writes version key and returns result', () async {
      final key = SPKeys.backupSaved + packageInfo.version;
      when(mockSettingsService.setValue(key, true)).thenAnswer((_) async => true);
      when(mockSettingsService.getBool(key)).thenReturn(true);

      final notifier = container.read(backupManagerProvider.notifier);
      final result = await notifier.setBackupSaved(true);

      verify(mockSettingsService.setValue(key, true)).called(1);
      verify(mockSettingsService.getBool(key)).called(1);
      expect(result, isTrue);
    });
  });
}
