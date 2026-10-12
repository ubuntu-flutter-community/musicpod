import 'package:musicpod/dependencies.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:musicpod/patch_notes/manager/recent_patch_notes_disposed_manager.dart';
import 'package:musicpod/patch_notes/manager/special_notes_disposed_manager.dart';
import 'package:musicpod/settings/data/shared_preferences_keys.dart';
import 'package:musicpod/settings/service/settings_service.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'patch_notes_manager_test.mocks.dart';

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

  group('RecentPatchNotesDisposedManager', () {
    test('initial state is false when stored version does not match', () {
      when(
        mockSettingsService.getString(SPKeys.patchNotesDisposed),
      ).thenReturn('1.9.0');

      final state = container.read(recentPatchNotesDisposedManagerProvider);
      expect(state, isFalse);
    });

    test(
      'initial state is true when stored version matches current version',
      () {
        when(
          mockSettingsService.getString(SPKeys.patchNotesDisposed),
        ).thenReturn('2.0.0');

        final state = container.read(recentPatchNotesDisposedManagerProvider);
        expect(state, isTrue);
      },
    );

    test('disposeNotes updates state to true and saves to settings', () async {
      when(
        mockSettingsService.getString(SPKeys.patchNotesDisposed),
      ).thenReturn(null);
      when(
        mockSettingsService.setValue(SPKeys.patchNotesDisposed, '2.0.0'),
      ).thenAnswer((_) async => true);

      expect(container.read(recentPatchNotesDisposedManagerProvider), isFalse);

      final notifier = container.read(
        recentPatchNotesDisposedManagerProvider.notifier,
      );
      await notifier.disposeNotes();

      expect(container.read(recentPatchNotesDisposedManagerProvider), isTrue);
      verify(
        mockSettingsService.setValue(SPKeys.patchNotesDisposed, '2.0.0'),
      ).called(1);
    });
  });

  group('SpecialNotesDisposedManager', () {
    test('initial state is false when stored version does not match', () {
      when(
        mockSettingsService.getString(SPKeys.specialNotesDisposed),
      ).thenReturn('1.9.0');

      final state = container.read(specialNotesDisposedManagerProvider);
      expect(state, isFalse);
    });

    test(
      'initial state is true when stored version matches current version',
      () {
        when(
          mockSettingsService.getString(SPKeys.specialNotesDisposed),
        ).thenReturn('2.0.0');

        final state = container.read(specialNotesDisposedManagerProvider);
        expect(state, isTrue);
      },
    );

    test('disposeNotes updates state to true and saves to settings', () async {
      when(
        mockSettingsService.getString(SPKeys.specialNotesDisposed),
      ).thenReturn(null);
      when(
        mockSettingsService.setValue(SPKeys.specialNotesDisposed, '2.0.0'),
      ).thenAnswer((_) async => true);

      expect(container.read(specialNotesDisposedManagerProvider), isFalse);

      final notifier = container.read(
        specialNotesDisposedManagerProvider.notifier,
      );
      await notifier.disposeNotes();

      expect(container.read(specialNotesDisposedManagerProvider), isTrue);
      verify(
        mockSettingsService.setValue(SPKeys.specialNotesDisposed, '2.0.0'),
      ).called(1);
    });
  });
}
