import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lrc/lrc.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:musicpod/common/data/audio.dart';
import 'package:musicpod/common/data/audio_type.dart';
import 'package:musicpod/dependencies.dart';
import 'package:musicpod/lyrics/data/lyrics_and_art_result_and_param.dart';
import 'package:musicpod/lyrics/lyrics_manager.dart';
import 'package:musicpod/lyrics/lyrics_service.dart';

import 'lyrics_manager_test.mocks.dart';

@GenerateMocks([LocalLyricsService, OnlineLyricsService])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;
  late MockLocalLyricsService mockLocalLyricsService;
  late MockOnlineLyricsService mockOnlineLyricsService;

  setUp(() async {
    await GetIt.I.reset();
    mockLocalLyricsService = MockLocalLyricsService();
    mockOnlineLyricsService = MockOnlineLyricsService();

    di.registerSingleton<LocalLyricsService>(mockLocalLyricsService);
    di.registerSingleton<OnlineLyricsService>(mockOnlineLyricsService);

    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  group('LyricsManager', () {
    test(
      'returns local lyrics when available without calling online service',
      () async {
        final localResult = LyricsAndArtResult(
          plainLyrics: 'Local lyrics content',
          lrcLines: [
            LrcLine(
              timestamp: Duration.zero,
              lyrics: 'Local line',
              type: LrcTypes.simple,
            ),
          ],
          artUrl: null,
        );

        when(
          mockLocalLyricsService.parseLocalLyrics(
            filePath: anyNamed('filePath'),
            inputString: anyNamed('inputString'),
          ),
        ).thenReturn(localResult);

        const param = LyricsAndArtParam(
          audio: Audio(
            title: 'Song A',
            artist: 'Artist A',
            audioType: AudioType.local,
          ),
          title: 'Song A',
          artist: 'Artist A',
          tryToFetchOnline: true,
        );

        final result = await container.read(
          lyricsManagerProvider(param).future,
        );

        expect(result, equals(localResult));
        verify(
          mockLocalLyricsService.parseLocalLyrics(
            filePath: anyNamed('filePath'),
            inputString: anyNamed('inputString'),
          ),
        ).called(1);
        verifyNever(
          mockOnlineLyricsService.fetchOnlineLyrics(
            title: anyNamed('title'),
            artist: anyNamed('artist'),
            album: anyNamed('album'),
            durationMs: anyNamed('durationMs'),
            source: anyNamed('source'),
          ),
        );
      },
    );

    test(
      'fetches online lyrics when local lyrics are empty and tryToFetchOnline is true',
      () async {
        when(
          mockLocalLyricsService.parseLocalLyrics(
            filePath: anyNamed('filePath'),
            inputString: anyNamed('inputString'),
          ),
        ).thenReturn(null);

        const onlineResult = LyricsAndArtResult(
          plainLyrics: 'Online lyrics content',
          lrcLines: null,
          artUrl: 'https://example.com/art.jpg',
        );

        when(
          mockOnlineLyricsService.fetchOnlineLyrics(
            title: anyNamed('title'),
            artist: anyNamed('artist'),
            album: anyNamed('album'),
            durationMs: anyNamed('durationMs'),
            source: anyNamed('source'),
          ),
        ).thenAnswer((_) async => onlineResult);

        const param = LyricsAndArtParam(
          audio: Audio(
            title: 'Song B',
            artist: 'Artist B',
            audioType: AudioType.local,
          ),
          title: 'Song B',
          artist: 'Artist B',
          tryToFetchOnline: true,
        );

        final result = await container.read(
          lyricsManagerProvider(param).future,
        );

        expect(result, equals(onlineResult));
        verify(
          mockLocalLyricsService.parseLocalLyrics(
            filePath: anyNamed('filePath'),
            inputString: anyNamed('inputString'),
          ),
        ).called(1);
        verify(
          mockOnlineLyricsService.fetchOnlineLyrics(
            title: anyNamed('title'),
            artist: anyNamed('artist'),
            album: anyNamed('album'),
            durationMs: anyNamed('durationMs'),
            source: anyNamed('source'),
          ),
        ).called(1);
      },
    );

    test(
      'does not fetch online lyrics when tryToFetchOnline is false',
      () async {
        when(
          mockLocalLyricsService.parseLocalLyrics(
            filePath: anyNamed('filePath'),
            inputString: anyNamed('inputString'),
          ),
        ).thenReturn(null);

        const param = LyricsAndArtParam(
          audio: Audio(
            title: 'Song C',
            artist: 'Artist C',
            audioType: AudioType.local,
          ),
          title: 'Song C',
          artist: 'Artist C',
          tryToFetchOnline: false,
        );

        final result = await container.read(
          lyricsManagerProvider(param).future,
        );

        expect(result, isNull);
        verify(
          mockLocalLyricsService.parseLocalLyrics(
            filePath: anyNamed('filePath'),
            inputString: anyNamed('inputString'),
          ),
        ).called(1);
        verifyNever(
          mockOnlineLyricsService.fetchOnlineLyrics(
            title: anyNamed('title'),
            artist: anyNamed('artist'),
            album: anyNamed('album'),
            durationMs: anyNamed('durationMs'),
            source: anyNamed('source'),
          ),
        );
      },
    );

    test(
      'keeps state alive across multiple reads without re-fetching',
      () async {
        when(
          mockLocalLyricsService.parseLocalLyrics(
            filePath: anyNamed('filePath'),
            inputString: anyNamed('inputString'),
          ),
        ).thenReturn(null);

        const onlineResult = LyricsAndArtResult(
          plainLyrics: 'Cached lyrics',
          lrcLines: null,
          artUrl: null,
        );

        when(
          mockOnlineLyricsService.fetchOnlineLyrics(
            title: anyNamed('title'),
            artist: anyNamed('artist'),
            album: anyNamed('album'),
            durationMs: anyNamed('durationMs'),
            source: anyNamed('source'),
          ),
        ).thenAnswer((_) async => onlineResult);

        const param = LyricsAndArtParam(
          audio: Audio(
            title: 'KeepAlive Song',
            artist: 'Artist D',
            audioType: AudioType.local,
          ),
          title: 'KeepAlive Song',
          artist: 'Artist D',
          tryToFetchOnline: true,
        );

        final first = await container.read(lyricsManagerProvider(param).future);
        expect(first, equals(onlineResult));

        // Second read should use the kept-alive cached value
        final second = await container.read(
          lyricsManagerProvider(param).future,
        );
        expect(second, equals(onlineResult));

        verify(
          mockOnlineLyricsService.fetchOnlineLyrics(
            title: anyNamed('title'),
            artist: anyNamed('artist'),
            album: anyNamed('album'),
            durationMs: anyNamed('durationMs'),
            source: anyNamed('source'),
          ),
        ).called(1);
      },
    );

    test('ref.invalidate forces re-fetching', () async {
      when(
        mockLocalLyricsService.parseLocalLyrics(
          filePath: anyNamed('filePath'),
          inputString: anyNamed('inputString'),
        ),
      ).thenReturn(null);

      const initialResult = LyricsAndArtResult(
        plainLyrics: 'Initial',
        lrcLines: null,
        artUrl: null,
      );
      const updatedResult = LyricsAndArtResult(
        plainLyrics: 'Updated',
        lrcLines: null,
        artUrl: null,
      );

      when(
        mockOnlineLyricsService.fetchOnlineLyrics(
          title: anyNamed('title'),
          artist: anyNamed('artist'),
          album: anyNamed('album'),
          durationMs: anyNamed('durationMs'),
          source: anyNamed('source'),
        ),
      ).thenAnswer((_) async => initialResult);

      const param = LyricsAndArtParam(
        audio: Audio(
          title: 'Retry Song',
          artist: 'Artist E',
          audioType: AudioType.local,
        ),
        title: 'Retry Song',
        artist: 'Artist E',
        tryToFetchOnline: true,
      );

      final first = await container.read(lyricsManagerProvider(param).future);
      expect(first, equals(initialResult));

      when(
        mockOnlineLyricsService.fetchOnlineLyrics(
          title: anyNamed('title'),
          artist: anyNamed('artist'),
          album: anyNamed('album'),
          durationMs: anyNamed('durationMs'),
          source: anyNamed('source'),
        ),
      ).thenAnswer((_) async => updatedResult);

      container.invalidate(lyricsManagerProvider(param));

      final second = await container.read(lyricsManagerProvider(param).future);
      expect(second, equals(updatedResult));

      verify(
        mockOnlineLyricsService.fetchOnlineLyrics(
          title: anyNamed('title'),
          artist: anyNamed('artist'),
          album: anyNamed('album'),
          durationMs: anyNamed('durationMs'),
          source: anyNamed('source'),
        ),
      ).called(2);
    });
  });
}
