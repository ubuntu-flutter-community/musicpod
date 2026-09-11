import 'package:flutter_test/flutter_test.dart';
import 'package:musicpod/common/util/family.dart';

class _TestResource {
  _TestResource(this.id);
  final String id;
  bool canDispose = false;
  bool isDisposed = false;
}

void main() {
  setUp(() async {
    await Family.reset();
  });

  tearDown(() async {
    await Family.reset();
  });

  group('Family', () {
    test('returns the same instance for identical (Type, id)', () {
      final a1 = Family.of(
        'item-1',
        () => _TestResource('item-1'),
        shouldDispose: (r) => r.canDispose,
        onDispose: (r) => r.isDisposed = true,
      );
      final a2 = Family.of(
        'item-1',
        () => _TestResource('item-1'),
        shouldDispose: (r) => r.canDispose,
        onDispose: (r) => r.isDisposed = true,
      );

      expect(identical(a1, a2), isTrue);
    });

    test('returns different instances for different IDs', () {
      final a = Family.of(
        'item-1',
        () => _TestResource('item-1'),
        shouldDispose: (r) => r.canDispose,
        onDispose: (r) => r.isDisposed = true,
      );
      final b = Family.of(
        'item-2',
        () => _TestResource('item-2'),
        shouldDispose: (r) => r.canDispose,
        onDispose: (r) => r.isDisposed = true,
      );

      expect(identical(a, b), isFalse);
      expect(a.id, equals('item-1'));
      expect(b.id, equals('item-2'));
    });

    test(
      'supports class name identifier for singleton/screen-scoped instances',
      () {
        final a = Family.of(
          '$_TestResource',
          () => _TestResource('scoped'),
          shouldDispose: (r) => r.canDispose,
          onDispose: (r) => r.isDisposed = true,
        );
        final b = Family.of(
          '$_TestResource',
          () => _TestResource('scoped'),
          shouldDispose: (r) => r.canDispose,
          onDispose: (r) => r.isDisposed = true,
        );

        expect(identical(a, b), isTrue);
      },
    );

    test(
      'get returns null when not registered, and returns instance when registered',
      () {
        expect(Family.get<_TestResource>('lookup-1'), isNull);

        final a = Family.of(
          'lookup-1',
          () => _TestResource('lookup-1'),
          shouldDispose: (r) => r.canDispose,
          onDispose: (r) => r.isDisposed = true,
        );

        expect(Family.get<_TestResource>('lookup-1'), equals(a));
        expect(Family.get<_TestResource>('lookup-other'), isNull);

        Family.dispose<_TestResource>('lookup-1');
        expect(Family.get<_TestResource>('lookup-1'), isNull);
      },
    );

    test('manually disposes an instance by id', () {
      final a = Family.of(
        'manual-1',
        () => _TestResource('manual-1'),
        shouldDispose: (r) => r.canDispose,
        onDispose: (r) => r.isDisposed = true,
      );

      final disposed = Family.dispose<_TestResource>('manual-1');
      expect(identical(disposed, a), isTrue);
      expect(a.isDisposed, isTrue);

      final fresh = Family.of(
        'manual-1',
        () => _TestResource('manual-1'),
        shouldDispose: (r) => r.canDispose,
        onDispose: (r) => r.isDisposed = true,
      );
      expect(identical(fresh, a), isFalse);
    });

    test('disposeAll disposes all instances of specified Type', () {
      final a = Family.of(
        'res-1',
        () => _TestResource('res-1'),
        shouldDispose: (r) => r.canDispose,
        onDispose: (r) => r.isDisposed = true,
      );
      final b = Family.of(
        'res-2',
        () => _TestResource('res-2'),
        shouldDispose: (r) => r.canDispose,
        onDispose: (r) => r.isDisposed = true,
      );

      Family.disposeAll<_TestResource>();
      expect(a.isDisposed, isTrue);
      expect(b.isDisposed, isTrue);
    });

    test('auto-disposes instance when shouldDispose returns true', () async {
      final res = Family.of(
        'auto-1',
        () => _TestResource('auto-1'),
        shouldDispose: (r) => r.canDispose,
        onDispose: (r) => r.isDisposed = true,
        autoDisposeAfter: const Duration(milliseconds: 50),
      );

      res.canDispose = true;
      expect(res.isDisposed, isFalse);

      await Future.delayed(const Duration(milliseconds: 100));

      expect(res.isDisposed, isTrue);
    });

    test('keeps instance alive while shouldDispose returns false', () async {
      final res = Family.of(
        'keep-alive-1',
        () => _TestResource('keep-alive-1'),
        shouldDispose: (r) => r.canDispose,
        onDispose: (r) => r.isDisposed = true,
        autoDisposeAfter: const Duration(milliseconds: 50),
      );

      res.canDispose = false;

      await Future.delayed(const Duration(milliseconds: 100));
      expect(res.isDisposed, isFalse);

      // Now permit disposal
      res.canDispose = true;
      await Future.delayed(const Duration(milliseconds: 100));
      expect(res.isDisposed, isTrue);
    });

    test('exposes diagnostic count, activeKeys, and isRegistered', () {
      expect(Family.count, equals(0));
      expect(Family.activeKeys, isEmpty);
      expect(Family.isRegistered<_TestResource>('diag-1'), isFalse);

      final res = Family.of(
        'diag-1',
        () => _TestResource('diag-1'),
        shouldDispose: (r) => r.canDispose,
        onDispose: (r) => r.isDisposed = true,
      );

      expect(res.id, equals('diag-1'));
      expect(Family.count, equals(1));
      expect(Family.activeKeys, contains((_TestResource, 'diag-1')));
      expect(Family.isRegistered<_TestResource>('diag-1'), isTrue);

      Family.dispose<_TestResource>('diag-1');
      expect(Family.count, equals(0));
      expect(Family.isRegistered<_TestResource>('diag-1'), isFalse);
    });

    test(
      're-accessing an existing instance refreshes the auto-dispose timer',
      () async {
        final res = Family.of(
          'refresh-1',
          () => _TestResource('refresh-1'),
          shouldDispose: (r) => r.canDispose,
          onDispose: (r) => r.isDisposed = true,
          autoDisposeAfter: const Duration(milliseconds: 60),
        );

        res.canDispose = true;

        // At 30ms, re-accessing the instance resets the 60ms timer (now expires at ~90ms)
        await Future.delayed(const Duration(milliseconds: 30));
        Family.of(
          'refresh-1',
          () => _TestResource('refresh-1'),
          shouldDispose: (r) => r.canDispose,
          onDispose: (r) => r.isDisposed = true,
          autoDisposeAfter: const Duration(milliseconds: 60),
        );

        // At 70ms: original timer (60ms) would have disposed it, but timer was refreshed
        await Future.delayed(const Duration(milliseconds: 40));
        expect(res.isDisposed, isFalse);
        expect(Family.isRegistered<_TestResource>('refresh-1'), isTrue);

        // At 120ms: refreshed timer has now elapsed and disposed it
        await Future.delayed(const Duration(milliseconds: 50));
        expect(res.isDisposed, isTrue);
        expect(Family.isRegistered<_TestResource>('refresh-1'), isFalse);
      },
    );

    test('handles exceptions in onDispose gracefully without crashing', () {
      Family.of(
        'throw-dispose',
        () => _TestResource('throw-dispose'),
        shouldDispose: (r) => r.canDispose,
        onDispose: (r) => throw Exception('Disposal failure'),
      );

      expect(
        () => Family.dispose<_TestResource>('throw-dispose'),
        returnsNormally,
      );
      expect(Family.isRegistered<_TestResource>('throw-dispose'), isFalse);
    });
  });
}
