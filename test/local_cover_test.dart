import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
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
    await GetIt.I.reset();
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  testWidgets('LocalCover loads image via class-based Riverpod provider', (
    tester,
  ) async {
    final fakeService = FakeLocalCoverService(
      delay: const Duration(milliseconds: 50),
      bytesToReturn: Uint8List.fromList([1, 2, 3, 4]),
    );

    GetIt.I.registerSingleton<LocalCoverService>(fakeService);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: LocalCover(
              albumId: 42,
              dimension: 100,
              fallback: Text('FALLBACK'),
              loadingWidget: Text('LOADING'),
            ),
          ),
        ),
      ),
    );

    // Initial frame: loading
    expect(find.text('LOADING'), findsOneWidget);
    expect(find.byType(Image), findsNothing);

    // Advance past delay & settle
    await tester.pump(const Duration(milliseconds: 60));
    await tester.pumpAndSettle();

    // After async load: Image is rendered!
    expect(find.byType(Image), findsOneWidget);
    expect(find.text('LOADING'), findsNothing);
    expect(find.text('FALLBACK'), findsNothing);
    expect(fakeService.callCount, 1);
  });

  testWidgets(
    'LocalCover retains cached image across unmount and remount within cache duration',
    (tester) async {
      final fakeService = FakeLocalCoverService(
        delay: const Duration(milliseconds: 50),
        bytesToReturn: Uint8List.fromList([1, 2, 3, 4]),
      );

      GetIt.I.registerSingleton<LocalCoverService>(fakeService);

      final scope = ProviderContainer();
      addTearDown(scope.dispose);

      // Mount first view (e.g. AlbumsView)
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: scope,
          child: const MaterialApp(
            home: Scaffold(
              body: LocalCover(
                albumId: 42,
                dimension: 100,
                fallback: Text('FALLBACK'),
                loadingWidget: Text('LOADING'),
              ),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 60));
      await tester.pumpAndSettle();
      expect(fakeService.callCount, 1);
      expect(find.byType(Image), findsOneWidget);

      // Switch view (e.g. to ArtistsView): LocalCover for album 42 unmounts
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: scope,
          child: const MaterialApp(
            home: Scaffold(body: Text('ARTISTS_VIEW')),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('ARTISTS_VIEW'), findsOneWidget);
      expect(find.byType(Image), findsNothing);

      // Remount LocalCover for album 42 (e.g. in ArtistsView's ArtistImage or back in AlbumsView)
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: scope,
          child: const MaterialApp(
            home: Scaffold(
              body: LocalCover(
                albumId: 42,
                dimension: 100,
                fallback: Text('FALLBACK'),
                loadingWidget: Text('LOADING'),
              ),
            ),
          ),
        ),
      );
      // Immediately renders image without re-loading or re-querying service!
      expect(find.byType(Image), findsOneWidget);
      expect(find.text('LOADING'), findsNothing);
      expect(fakeService.callCount, 1);

      scope.dispose();
    },
  );

  testWidgets(
    'LocalCover disposes and reloads once cache duration expires',
    (tester) async {
      final fakeService = FakeLocalCoverService(
        delay: const Duration(milliseconds: 50),
        bytesToReturn: Uint8List.fromList([1, 2, 3, 4]),
      );

      GetIt.I.registerSingleton<LocalCoverService>(fakeService);

      final scope = ProviderContainer();
      addTearDown(scope.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: scope,
          child: const MaterialApp(
            home: Scaffold(
              body: LocalCover(
                albumId: 42,
                dimension: 100,
                fallback: Text('FALLBACK'),
                loadingWidget: Text('LOADING'),
              ),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 60));
      await tester.pumpAndSettle();
      expect(fakeService.callCount, 1);

      // Unmount LocalCover
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: scope,
          child: const MaterialApp(home: Scaffold(body: SizedBox())),
        ),
      );
      await tester.pump();

      // Advance past the 5-minute cache grace period
      await tester.pump(const Duration(minutes: 5, seconds: 1));

      // Remount: provider was disposed, so it queries again
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: scope,
          child: const MaterialApp(
            home: Scaffold(
              body: LocalCover(
                albumId: 42,
                dimension: 100,
                fallback: Text('FALLBACK'),
                loadingWidget: Text('LOADING'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('LOADING'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 60));
      await tester.pumpAndSettle();

      expect(fakeService.callCount, 2);
      expect(find.byType(Image), findsOneWidget);

      scope.dispose();
    },
  );
}


