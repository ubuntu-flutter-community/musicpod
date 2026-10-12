import 'package:musicpod/dependencies.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:musicpod/settings/manager/settings_manager.dart';
import 'package:musicpod/settings/service/settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;
  late SharedPreferences prefs;

  setUp(() async {
    await GetIt.I.reset();
    SharedPreferences.setMockInitialValues({
      'test_bool': true,
      'test_int': 42,
      'test_double': 3.14,
      'test_string': 'hello',
      'test_list': ['a', 'b'],
    });
    prefs = await SharedPreferences.getInstance();
    di.registerSingleton<SettingsService>(
      SettingsService(sharedPreferences: prefs),
    );
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  group('SettingsScrollIndex', () {
    test('initializes with 0 and can be set', () {
      expect(container.read(settingsScrollIndexProvider), equals(0));
      container.read(settingsScrollIndexProvider.notifier).set(5);
      expect(container.read(settingsScrollIndexProvider), equals(5));
      container.read(settingsScrollIndexProvider.notifier).index = 10;
      expect(container.read(settingsScrollIndexProvider), equals(10));
    });
  });

  group('SettingsBoolManager', () {
    test('reads existing bool value', () {
      final value = container.read(settingsBoolManagerProvider('test_bool'));
      expect(value, isTrue);
    });

    test('returns null when key does not exist', () {
      final value = container.read(settingsBoolManagerProvider('missing_bool'));
      expect(value, isNull);
    });

    test('updates bool value via set', () async {
      await container
          .read(settingsBoolManagerProvider('test_bool').notifier)
          .set(false);
      expect(container.read(settingsBoolManagerProvider('test_bool')), isFalse);
      expect(prefs.getBool('test_bool'), isFalse);
    });

    test('toggles bool value', () async {
      await container
          .read(settingsBoolManagerProvider('test_bool').notifier)
          .toggle();
      expect(container.read(settingsBoolManagerProvider('test_bool')), isFalse);

      await container
          .read(settingsBoolManagerProvider('test_bool').notifier)
          .toggle();
      expect(container.read(settingsBoolManagerProvider('test_bool')), isTrue);
    });

    test('toggling missing key defaults from false to true', () async {
      await container
          .read(settingsBoolManagerProvider('missing_bool').notifier)
          .toggle();
      expect(
        container.read(settingsBoolManagerProvider('missing_bool')),
        isTrue,
      );
    });
  });

  group('SettingsIntManager', () {
    test('reads existing int value', () {
      final value = container.read(settingsIntManagerProvider('test_int'));
      expect(value, equals(42));
    });

    test('returns null when key does not exist', () {
      final value = container.read(settingsIntManagerProvider('missing_int'));
      expect(value, isNull);
    });

    test('updates int value via set', () async {
      await container
          .read(settingsIntManagerProvider('test_int').notifier)
          .set(100);
      expect(
        container.read(settingsIntManagerProvider('test_int')),
        equals(100),
      );
      expect(prefs.getInt('test_int'), equals(100));
    });
  });

  group('SettingsDoubleManager', () {
    test('reads existing double value', () {
      final value = container.read(
        settingsDoubleManagerProvider('test_double'),
      );
      expect(value, equals(3.14));
    });

    test('returns null when key does not exist', () {
      final value = container.read(
        settingsDoubleManagerProvider('missing_double'),
      );
      expect(value, isNull);
    });

    test('updates double value via set', () async {
      await container
          .read(settingsDoubleManagerProvider('test_double').notifier)
          .set(2.718);
      expect(
        container.read(settingsDoubleManagerProvider('test_double')),
        equals(2.718),
      );
      expect(prefs.getDouble('test_double'), equals(2.718));
    });
  });

  group('SettingsStringManager', () {
    test('reads existing string value', () {
      final value = container.read(
        settingsStringManagerProvider('test_string'),
      );
      expect(value, equals('hello'));
    });

    test('returns null when key does not exist', () {
      final value = container.read(
        settingsStringManagerProvider('missing_string'),
      );
      expect(value, isNull);
    });

    test('updates string value via set', () async {
      await container
          .read(settingsStringManagerProvider('test_string').notifier)
          .set('world');
      expect(
        container.read(settingsStringManagerProvider('test_string')),
        equals('world'),
      );
      expect(prefs.getString('test_string'), equals('world'));
    });
  });

  group('SettingsStringListManager', () {
    test('reads existing string list value', () {
      final value = container.read(
        settingsStringListManagerProvider('test_list'),
      );
      expect(value, equals(['a', 'b']));
    });

    test('returns null when key does not exist', () {
      final value = container.read(
        settingsStringListManagerProvider('missing_list'),
      );
      expect(value, isNull);
    });

    test('updates string list via set', () async {
      await container
          .read(settingsStringListManagerProvider('test_list').notifier)
          .set(['x', 'y', 'z']);
      expect(
        container.read(settingsStringListManagerProvider('test_list')),
        equals(['x', 'y', 'z']),
      );
      expect(prefs.getStringList('test_list'), equals(['x', 'y', 'z']));
    });

    test('adds an item to string list', () async {
      await container
          .read(settingsStringListManagerProvider('test_list').notifier)
          .add('c');
      expect(
        container.read(settingsStringListManagerProvider('test_list')),
        equals(['a', 'b', 'c']),
      );
    });

    test('does not add duplicate items to string list', () async {
      await container
          .read(settingsStringListManagerProvider('test_list').notifier)
          .add('a');
      expect(
        container.read(settingsStringListManagerProvider('test_list')),
        equals(['a', 'b']),
      );
    });

    test('removes an item from string list', () async {
      await container
          .read(settingsStringListManagerProvider('test_list').notifier)
          .remove('a');
      expect(
        container.read(settingsStringListManagerProvider('test_list')),
        equals(['b']),
      );
    });

    test('handles add and remove on previously missing list', () async {
      await container
          .read(settingsStringListManagerProvider('new_list').notifier)
          .add('first');
      expect(
        container.read(settingsStringListManagerProvider('new_list')),
        equals(['first']),
      );

      await container
          .read(settingsStringListManagerProvider('new_list').notifier)
          .remove('first');
      expect(
        container.read(settingsStringListManagerProvider('new_list')),
        isEmpty,
      );
    });
  });
}
