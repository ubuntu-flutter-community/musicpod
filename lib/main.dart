import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:collection/collection.dart';
import 'package:desktop_notifications/desktop_notifications.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:metadata_god/metadata_god.dart';
import 'package:mpris_service/mpris_service.dart';
import 'package:musicpod/service/library_service.dart';
import 'package:musicpod/service/podcast_service.dart';
import 'package:musicpod/service/radio_service.dart';
import 'package:musicpod/utils.dart';
import 'package:radio_browser_api/radio_browser_api.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import 'app/music_app.dart';

Future<void> main() async {
  final mpris = await MPRIS.create(
    busName: 'org.mpris.MediaPlayer2.musicpod',
    identity: 'Musicpod',
    desktopEntry: '/var/lib/snapd/desktop/applications/musicpod',
  );

  registerService<MPRIS>(() => mpris);
  registerService<LibraryService>(LibraryService.new);
  registerService<PodcastService>(PodcastService.new);
  registerService<Connectivity>(Connectivity.new);

  registerService<RadioService>(
    () => RadioService(
      const RadioBrowserApi.fromHost('de1.api.radio-browser.info'),
    ),
  );

  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  MetadataGod.initialize();
  await YaruWindowTitleBar.ensureInitialized();

  // TODO: check for internet access
  // Update and notify id new podcasts are available
  final podcastService = getService<PodcastService>();
  final libraryService = getService<LibraryService>();
  libraryService.init().then((_) {
    // TODO: add splash screen
    for (final podcast in libraryService.podcasts.entries) {
      if (podcast.value.firstOrNull?.website != null) {
        podcastService
            .findEpisodes(
          url: podcast.value.firstOrNull!.website!,
        )
            .then((audios) {
          if (!listsAreEqual(
            audios.toList(),
            podcast.value.toList(),
          )) {
            libraryService.updatePodcast(podcast.key, audios);
            final client = NotificationsClient();
            client
                .notify(
                  'New episodes available: ${podcast.key}',
                  appIcon: 'music-app',
                  appName: 'musicpod',
                )
                .then((_) => client.close());
          }
        });
      }
    }
  });
  runApp(const MusicApp());
}
