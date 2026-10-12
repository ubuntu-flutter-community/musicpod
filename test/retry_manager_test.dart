import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:musicpod/common/data/retry_capsule.dart';
import 'package:musicpod/common/manager/retry_manager.dart';
import 'package:musicpod/common/view/error_retry_body.dart';
import 'package:musicpod/l10n/app_localizations.dart';

void main() {
  test('RetryManager initializes and ticks down cooldown', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    var retryCount = 0;
    final capsule = RetryCapsule(
      retryViewId: 'test_view',
      cooldownStartValue: 2,
      autoRetry: false,
      onRetry: () => retryCount++,
    );

    final sub = container.listen(retryManagerProvider(capsule), (_, __) {});
    addTearDown(sub.close);

    expect(container.read(retryManagerProvider(capsule)), 2);

    await Future<void>.delayed(const Duration(milliseconds: 1050));
    expect(container.read(retryManagerProvider(capsule)), 1);

    await Future<void>.delayed(const Duration(milliseconds: 1050));
    expect(container.read(retryManagerProvider(capsule)), 0);
    // autoRetry is false, so onRetry should not have been called automatically
    expect(retryCount, 0);
  });

  test('RetryManager autoRetries when countdown reaches 0', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    var retryCount = 0;
    final capsule = RetryCapsule(
      retryViewId: 'auto_retry_view',
      cooldownStartValue: 1,
      autoRetry: true,
      autoIncrementCooldown: true,
      onRetry: () => retryCount++,
    );

    final sub = container.listen(retryManagerProvider(capsule), (_, __) {});
    addTearDown(sub.close);

    expect(container.read(retryManagerProvider(capsule)), 1);

    // Wait for 1 second tick to decrement to 0, then next tick to auto-retry
    await Future<void>.delayed(const Duration(milliseconds: 2150));
    expect(retryCount, 1);
    expect(container.read(retryManagerProvider(capsule)), 2);
  });

  test('RetryManager manualRetry triggers onRetry and resets countdown', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    var retryCount = 0;
    final capsule = RetryCapsule(
      retryViewId: 'manual_retry_view',
      cooldownStartValue: 5,
      autoRetry: false,
      onRetry: () => retryCount++,
    );

    final notifier = container.read(retryManagerProvider(capsule).notifier);
    expect(container.read(retryManagerProvider(capsule)), 5);

    notifier.manualRetry();
    expect(retryCount, 1);
    expect(container.read(retryManagerProvider(capsule)), 5);
  });

  testWidgets('ErrorRetryBody renders and updates with retryManagerProvider', (
    tester,
  ) async {
    var retried = false;
    final capsule = RetryCapsule(
      retryViewId: 'error_body_test',
      cooldownStartValue: 0,
      autoRetry: false,
      onRetry: () => retried = true,
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: ErrorRetryBody(
              error: Exception('Test Error'),
              stackTrace: StackTrace.empty,
              retryCapsule: capsule,
            ),
          ),
        ),
      ),
    );

    expect(find.byType(ErrorRetryBody), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    expect(retried, true);
  });
}
