import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:musicpod/app/app_config.dart';
import 'package:musicpod/app/window_size_to_settings_listener.dart';
import 'package:musicpod/player/service/player_service.dart';
import 'package:musicpod/settings/data/shared_preferences_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

class FakeWindowManager extends Fake implements WindowManager {
  final List<WindowListener> listeners = [];
  bool preventCloseSet = false;
  bool destroyed = false;
  int destroyCallCount = 0;
  Size currentSize = const Size(800, 600);

  @override
  void addListener(WindowListener listener) {
    listeners.add(listener);
  }

  @override
  void removeListener(WindowListener listener) {
    listeners.remove(listener);
  }

  @override
  Future<void> setPreventClose(bool value) async {
    preventCloseSet = value;
  }

  @override
  Future<bool> isPreventClose() async => preventCloseSet;

  @override
  Future<void> setFullScreen(bool isFullScreen) async {}

  @override
  Future<void> maximize({bool vertically = false}) async {}

  @override
  Future<void> setSize(Size size, {bool animate = false}) async {
    currentSize = size;
  }

  @override
  Future<Size> getSize() async => currentSize;

  @override
  Future<void> destroy() async {
    destroyed = true;
    destroyCallCount++;
  }
}

class FakePlayerService extends Fake implements PlayerService {
  bool shutdownCalled = false;
  int shutdownCallCount = 0;
  bool shouldThrowOnShutdown = false;

  @override
  Future<void> shutdown() async {
    shutdownCallCount++;
    shutdownCalled = true;
    if (shouldThrowOnShutdown) {
      throw Exception('Simulated shutdown failure');
    }
  }

  @override
  Future<void> persistPlayerState() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeWindowManager fakeWindowManager;
  late FakePlayerService fakePlayerService;
  late SharedPreferences sp;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    sp = await SharedPreferences.getInstance();
    fakeWindowManager = FakeWindowManager();
    fakePlayerService = FakePlayerService();
    AppConfig.windowManagerImplemented = true;
  });

  test('init sets preventClose to true on desktop', () async {
    final listener = WindowSizeToSettingsListener(
      sharedPreferences: sp,
      playerService: fakePlayerService,
      windowManager: fakeWindowManager,
    );

    expect(fakeWindowManager.listeners.contains(listener), isTrue);

    await listener.init();

    expect(fakeWindowManager.preventCloseSet, isTrue);
  });

  test('onWindowClose invokes PlayerService.shutdown and windowManager.destroy', () async {
    final listener = WindowSizeToSettingsListener(
      sharedPreferences: sp,
      playerService: fakePlayerService,
      windowManager: fakeWindowManager,
    );
    await listener.init();

    await listener.onWindowClose();

    expect(fakePlayerService.shutdownCalled, isTrue);
    expect(fakeWindowManager.destroyed, isTrue);
    expect(fakeWindowManager.destroyCallCount, 1);
  });

  test('onWindowClose is idempotent and guards against re-entrancy', () async {
    final listener = WindowSizeToSettingsListener(
      sharedPreferences: sp,
      playerService: fakePlayerService,
      windowManager: fakeWindowManager,
    );
    await listener.init();

    // Call onWindowClose multiple times concurrently
    await Future.wait([
      listener.onWindowClose(),
      listener.onWindowClose(),
      listener.onWindowClose(),
    ]);

    expect(fakePlayerService.shutdownCallCount, 1);
    expect(fakeWindowManager.destroyCallCount, 1);
  });

  test('onWindowClose always calls windowManager.destroy even if shutdown throws', () async {
    fakePlayerService.shouldThrowOnShutdown = true;

    final listener = WindowSizeToSettingsListener(
      sharedPreferences: sp,
      playerService: fakePlayerService,
      windowManager: fakeWindowManager,
    );
    await listener.init();

    await listener.onWindowClose();

    expect(fakePlayerService.shutdownCalled, isTrue);
    expect(fakeWindowManager.destroyed, isTrue);
  });

  test('onWindowClose saves window dimensions if saveWindowSize is enabled and not maximized', () async {
    await sp.setBool(SPKeys.saveWindowSize, true);

    final listener = WindowSizeToSettingsListener(
      sharedPreferences: sp,
      playerService: fakePlayerService,
      windowManager: fakeWindowManager,
    );
    await listener.init();

    fakeWindowManager.currentSize = const Size(1024, 768);

    await listener.onWindowClose();

    expect(sp.getInt(SPKeys.windowWidth), 1024);
    expect(sp.getInt(SPKeys.windowHeight), 768);
  });

  test('dispose removes listener from windowManager', () async {
    final listener = WindowSizeToSettingsListener(
      sharedPreferences: sp,
      playerService: fakePlayerService,
      windowManager: fakeWindowManager,
    );

    expect(fakeWindowManager.listeners.contains(listener), isTrue);

    listener.dispose();

    expect(fakeWindowManager.listeners.contains(listener), isFalse);
  });
}
