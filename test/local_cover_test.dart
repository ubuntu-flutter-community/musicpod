import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:musicpod/common/logging.dart';
import 'package:musicpod/common/util/family.dart';
import 'package:musicpod/extensions/command_x.dart';
import 'package:musicpod/local_audio/manager/local_cover_manager.dart';
import 'package:musicpod/local_audio/service/local_cover_service.dart';
import 'package:musicpod/local_audio/view/local_cover.dart';

class FakeLocalCoverService extends Fake implements LocalCoverService {
  FakeLocalCoverService({required this.delay, required this.bytesToReturn});
  final Duration delay;
  final Uint8List? bytesToReturn;
  int callCount = 0;

  @override
  Future<Uint8List?> getCover({required int albumId}) async {
    callCount++;
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    return bytesToReturn;
  }
}

void main() {
  setUp(() async {
    await Family.reset();
    await GetIt.I.reset();
  });

  tearDown(() async {
    await Family.reset();
    await GetIt.I.reset();
  });

  testWidgets('Check listenerCount and safeToDispose for LocalCover', (
    tester,
  ) async {
    final fakeService = FakeLocalCoverService(
      delay: const Duration(milliseconds: 50),
      bytesToReturn: Uint8List.fromList([1, 2, 3, 4]),
    );

    GetIt.I.registerFactoryParam<LocalCoverManager, int, void>(
      (albumId, _) => LocalCoverManager.create(
        albumId: albumId,
        localCoverService: fakeService,
      ),
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LocalCover(
            albumId: 42,
            dimension: 100,
            fallback: const Text('FALLBACK'),
          ),
        ),
      ),
    );

    final manager = di<LocalCoverManager>(param1: 42);
    Logger.i('During run:');
    Logger.i('  isRunning: ${manager.command.isRunning.value}');
    Logger.i('  command.listenerCount: ${manager.command.listenerCount}');
    Logger.i('  safeToDispose: ${manager.command.safeToDispose}');

    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();

    Logger.i('After run (while widget is mounted):');
    Logger.i('  isRunning: ${manager.command.isRunning.value}');
    Logger.i('  command.listenerCount: ${manager.command.listenerCount}');
    Logger.i('  safeToDispose: ${manager.command.safeToDispose}');
    Logger.i('  Found Image: ${find.byType(Image).evaluate().length}');
    Logger.i('  Found FALLBACK: ${find.text('FALLBACK').evaluate().length}');

    // Let 6 seconds pass: should NOT be disposed while mounted!
    await tester.pump(const Duration(seconds: 6));
    Logger.i('After 6 seconds (while widget is still mounted):');
    Logger.i(
      '  isRegistered in Family: ${Family.isRegistered<LocalCoverManager>(42)}',
    );

    // Now unmount widget
    await tester.pumpWidget(const SizedBox());
    Logger.i('After unmount:');
    Logger.i('  command.listenerCount: ${manager.command.listenerCount}');
    Logger.i('  safeToDispose: ${manager.command.safeToDispose}');

    // Let 6 seconds pass after unmount: SHOULD be disposed now!
    await tester.pump(const Duration(seconds: 6));
    Logger.i('After 6 seconds (after unmount):');
    Logger.i(
      '  isRegistered in Family: ${Family.isRegistered<LocalCoverManager>(42)}',
    );

    await Family.reset();
  });
}
