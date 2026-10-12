import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:musicpod/app/full_window_mode_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  group('FullWindowModeManager', () {
    test('initial state is false', () {
      expect(container.read(fullWindowModeManagerProvider), isFalse);
    });

    test('setFullWindowMode updates state', () async {
      final notifier = container.read(fullWindowModeManagerProvider.notifier);
      await notifier.setFullWindowMode(true);
      expect(container.read(fullWindowModeManagerProvider), isTrue);

      await notifier.setFullWindowMode(false);
      expect(container.read(fullWindowModeManagerProvider), isFalse);
    });

    test('setFullWindowMode with null retains current state', () async {
      final notifier = container.read(fullWindowModeManagerProvider.notifier);
      await notifier.setFullWindowMode(true);
      expect(container.read(fullWindowModeManagerProvider), isTrue);

      await notifier.setFullWindowMode(null);
      expect(container.read(fullWindowModeManagerProvider), isTrue);
    });

    test('toggleFullWindowMode toggles state', () async {
      final notifier = container.read(fullWindowModeManagerProvider.notifier);
      expect(container.read(fullWindowModeManagerProvider), isFalse);

      await notifier.toggleFullWindowMode();
      expect(container.read(fullWindowModeManagerProvider), isTrue);

      await notifier.toggleFullWindowMode();
      expect(container.read(fullWindowModeManagerProvider), isFalse);
    });
  });
}
