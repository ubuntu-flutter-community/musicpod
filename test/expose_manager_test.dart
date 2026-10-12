import 'package:musicpod/dependencies.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:musicpod/expose/data/last_fm_credentials.dart';
import 'package:musicpod/expose/manager/expose_manager.dart';
import 'package:musicpod/expose/service/expose_service.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

import 'expose_manager_test.mocks.dart';

@GenerateMocks([ExposeService])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;
  late MockExposeService mockExposeService;
  late SafeValueNotifier<bool> isAuthorizedNotifier;

  setUp(() async {
    await GetIt.I.reset();
    mockExposeService = MockExposeService();
    isAuthorizedNotifier = SafeValueNotifier<bool>(false);

    when(mockExposeService.isLastFmAuthorized).thenReturn(isAuthorizedNotifier);
    when(mockExposeService.initListenBrains(any)).thenAnswer((_) async {});
    when(
      mockExposeService.authorizeLastFm(
        apiKey: anyNamed('apiKey'),
        apiSecret: anyNamed('apiSecret'),
      ),
    ).thenAnswer((_) async {});

    di.registerSingleton<ExposeService>(mockExposeService);

    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  group('ExposeManager', () {
    test('initial state reflects isLastFmAuthorized value', () {
      isAuthorizedNotifier.value = false;
      expect(container.read(exposeManagerProvider), isFalse);

      final container2 = ProviderContainer();
      isAuthorizedNotifier.value = true;
      expect(container2.read(exposeManagerProvider), isTrue);
      container2.dispose();
    });

    test('state updates when isLastFmAuthorized changes', () {
      isAuthorizedNotifier.value = false;
      expect(container.read(exposeManagerProvider), isFalse);

      isAuthorizedNotifier.value = true;
      expect(container.read(exposeManagerProvider), isTrue);

      isAuthorizedNotifier.value = false;
      expect(container.read(exposeManagerProvider), isFalse);
    });

    test('initListenBrains forwards apiKey to ExposeService', () async {
      await container
          .read(exposeManagerProvider.notifier)
          .initListenBrains('test-listenbrainz-key');

      verify(
        mockExposeService.initListenBrains('test-listenbrainz-key'),
      ).called(1);
    });

    test('authorizeLastFm forwards credentials to ExposeService', () async {
      await container
          .read(exposeManagerProvider.notifier)
          .authorizeLastFm(
            LastFmCredentials(
              apiKey: 'test-lastfm-key',
              apiSecret: 'test-lastfm-secret',
            ),
          );

      verify(
        mockExposeService.authorizeLastFm(
          apiKey: 'test-lastfm-key',
          apiSecret: 'test-lastfm-secret',
        ),
      ).called(1);
    });
  });
}
