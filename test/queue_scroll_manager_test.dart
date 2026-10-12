import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:musicpod/player/manager/queue_scroll_manager.dart';

void main() {
  group('QueueScrollManager', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state has default values', () {
      final state = container.read(queueScrollManagerProvider);
      expect(state.autoScroll, isTrue);
      expect(state.isJumping, isFalse);
      expect(state.showSpinner, isFalse);
    });

    test('toggleAutoScroll toggles autoScroll value', () {
      final notifier = container.read(queueScrollManagerProvider.notifier);

      notifier.toggleAutoScroll();
      expect(container.read(queueScrollManagerProvider).autoScroll, isFalse);

      notifier.toggleAutoScroll();
      expect(container.read(queueScrollManagerProvider).autoScroll, isTrue);
    });

    test('setJumping updates isJumping value', () {
      final notifier = container.read(queueScrollManagerProvider.notifier);

      notifier.setJumping(true);
      expect(container.read(queueScrollManagerProvider).isJumping, isTrue);

      notifier.setJumping(false);
      expect(container.read(queueScrollManagerProvider).isJumping, isFalse);
    });

    test('setShowSpinner updates showSpinner value', () {
      final notifier = container.read(queueScrollManagerProvider.notifier);

      notifier.setShowSpinner(true);
      expect(container.read(queueScrollManagerProvider).showSpinner, isTrue);

      notifier.setShowSpinner(false);
      expect(container.read(queueScrollManagerProvider).showSpinner, isFalse);
    });
  });
}
