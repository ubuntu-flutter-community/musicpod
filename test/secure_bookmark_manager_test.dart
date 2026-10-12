import 'package:musicpod/dependencies.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:musicpod/external_path/manager/secure_bookmark_manager.dart';
import 'package:musicpod/external_path/service/secure_bookmark_service.dart';

import 'secure_bookmark_manager_test.mocks.dart';

@GenerateMocks([SecureBookmarkService])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;
  late MockSecureBookmarkService mockService;

  setUp(() async {
    await GetIt.I.reset();
    mockService = MockSecureBookmarkService();
    when(mockService.restoreAllSavedBookmarks()).thenAnswer((_) async => true);

    di.registerSingleton<SecureBookmarkService>(mockService);
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  group('SecureBookmarkManager', () {
    test('initial state is false and does not call service until restore', () {
      expect(container.read(secureBookmarkManagerProvider), isFalse);
      verifyNever(mockService.restoreAllSavedBookmarks());
    });

    test(
      'restore calls restoreAllSavedBookmarks and updates state to true',
      () async {
        final result = await container
            .read(secureBookmarkManagerProvider.notifier)
            .restore();

        expect(result, isTrue);
        expect(container.read(secureBookmarkManagerProvider), isTrue);
        verify(mockService.restoreAllSavedBookmarks()).called(1);
      },
    );

    test(
      'consecutive restore calls do not re-invoke service if already true',
      () async {
        final first = await container
            .read(secureBookmarkManagerProvider.notifier)
            .restore();
        expect(first, isTrue);

        final second = await container
            .read(secureBookmarkManagerProvider.notifier)
            .restore();
        expect(second, isTrue);

        verify(mockService.restoreAllSavedBookmarks()).called(1);
      },
    );
  });
}
