import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';
import 'package:m3u_parser_nullsafe/m3u_parser_nullsafe.dart';
import 'package:opml/opml.dart';
import 'package:path/path.dart';
import 'package:pls/pls.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

import '../../common/data/audio.dart';
import '../../common/data/audio_type.dart';
import '../../common/logging.dart';
import '../../extensions/media_file_x.dart';
import '../../external_path/service/external_path_service.dart';
import '../../local_audio/data/playlist_action.dart';
import '../../local_audio/manager/find_album_manager.dart';
import '../../local_audio/manager/pinned_album_ids_manager.dart';
import '../../local_audio/manager/playlist_ids_manager.dart';
import '../../local_audio/manager/playlist_manager.dart';
import '../../podcasts/data/podcast_toggle_capsule.dart';
import '../../podcasts/manager/episodes_manager.dart';
import '../../podcasts/manager/podcast_short_info_manager.dart';
import '../../podcasts/manager/subscribed_podcasts_manager.dart';
import '../../radio/manager/radio_manager.dart';
import '../../radio/manager/radio_star_station_manager.dart';
import '../../radio/service/radio_service.dart';

@Injectable(cache: true)
class CustomContentManager {
  CustomContentManager({
    required ExternalPathService externalPathService,
    required PlaylistIDsManager playlistIDsManager,
    required PinnedAlbumIDsManager pinnedAlbumIDsManager,
    required SubscribedPodcastsManager podcastService,
    required RadioService radioService,
  }) : _externalPathService = externalPathService,
       _subscribedPodcastsManager = podcastService,
       _radioService = radioService,
       _playlistIDsManager = playlistIDsManager,
       _pinnedAlbumIDsManager = pinnedAlbumIDsManager {
    Logger.o(tag: '$CustomContentManager');
  }

  final ExternalPathService _externalPathService;
  final SubscribedPodcastsManager _subscribedPodcastsManager;
  final PlaylistIDsManager _playlistIDsManager;
  final PinnedAlbumIDsManager _pinnedAlbumIDsManager;
  final RadioService _radioService;

  final externalPlaylistsDraft = MapNotifier<String, List<Audio>>();
  Future<void> addPlaylists() async {
    final more = await _loadPlaylistsFromFile();
    externalPlaylistsDraft.addEntries(more.entries);
  }

  void removeExternalPlaylistFromDraft({required String name}) =>
      externalPlaylistsDraft.remove(name);

  late final Command<void, void> importExternalPlaylistsCommand =
      Command.createAsyncNoParamNoResult(() async {
        for (final entry in externalPlaylistsDraft.entries) {
          await _playlistIDsManager.command.runAsync(
            PlaylistChange(
              id: entry.key,
              audios: entry.value,
              action: PlaylistAction.create,
              external: true,
            ),
          );
        }
      });

  Future<Map<String, List<Audio>>> _loadPlaylistsFromFile() async {
    final Map<String, List<Audio>> lists = {};

    try {
      final paths = await _externalPathService.getPathsOfFiles();
      for (var path in paths) {
        if (path.endsWith('.m3u')) {
          lists[basename(path)] = await compute(_parseM3uPlaylist, path);
        } else if (path.endsWith('.pls')) {
          lists[basename(path)] = await compute(_parsePlsPlaylist, path);
        }
      }
    } on Exception catch (e, s) {
      Logger.e(e, trace: s, tag: '$CustomContentManager');
    }

    return lists;
  }

  Future<void> exportPlaylistToM3u({
    required String id,
    required List<Audio> audios,
  }) async {
    final path = await _externalPathService.getPathOfDirectory();
    if (path == null) return;
    _exportPlaylistToM3u(audios: audios, basePath: path, id: id);
  }

  Future<bool> exportPlaylistsAndPinnedAlbumsToM3Us() async {
    final albums = <({String id, List<Audio> audios})>[];
    for (var e in (await _pinnedAlbumIDsManager.command.runAsync())) {
      albums.add((
        id: e.toString(),
        audios: await di<FindAlbumManager>(param1: e).command.runAsync() ?? [],
      ));
    }

    final List<({String id, List<Audio> audios})> list = [
      ...(await _playlistIDsManager.command.runAsync()).map(
        (e) => (
          id: e,
          audios: (di<PlaylistManager>(param1: e).command.value) ?? [],
        ),
      ),
      ...albums,
    ];

    final path = await _externalPathService.getPathOfDirectory();
    if (path == null) return false;

    for (var e in list) {
      _exportPlaylistToM3u(audios: e.audios, basePath: path, id: e.id);
    }
    return true;
  }

  void _exportPlaylistToM3u({
    required List<Audio> audios,
    required String basePath,
    required String id,
  }) {
    final m3uAsString = StringBuffer();
    m3uAsString.writeln('#EXTM3U');
    for (var audio in audios.where((e) => e.isLocal)) {
      if (audio.url != null) {
        m3uAsString.writeln('#EXTINF:-1, ${audio.artist} - ${audio.title}');
        m3uAsString.writeln(audio.url);
      } else {
        m3uAsString.writeln('#EXTINF:-1, ${audio.artist} - ${audio.title}');
        m3uAsString.writeln(audio.path);
      }
    }
    try {
      File(join(basePath, '$id.m3u')).writeAsStringSync(m3uAsString.toString());
    } on Exception catch (e, s) {
      Logger.e(e, trace: s, tag: '$CustomContentManager');
    }
  }

  Future<void> importPodcastsFromOpmlFile() async {
    final path = await _externalPathService.getPathOfFile();

    if (path == null) {
      return;
    }
    final file = File(path);
    if (!file.existsSync()) return;
    final xml = file.readAsStringSync();
    final doc = OpmlDocument.parse(xml);

    final podcasts = <({String feedUrl})>[];
    for (var outline in doc.body) {
      if (outline.xmlUrl != null) {
        podcasts.add((feedUrl: outline.xmlUrl!));
      } else {
        for (var outlineChild in (outline.children ?? <OpmlOutline>[]).where(
          (e) => e.xmlUrl != null,
        )) {
          podcasts.add((feedUrl: outlineChild.xmlUrl!));
        }
      }
    }

    if (podcasts.isNotEmpty) {
      for (final podcast in podcasts) {
        final episodes = (await di<EpisodesManager>(
          param1: podcast.feedUrl,
        ).command.runAsync())?.episodes;
        final shortInfo = await di<PodcastShortInfoManager>(
          param1: podcast.feedUrl,
        ).command.runAsync();
        final artist = shortInfo?.artist;
        final imageUrl = shortInfo?.imageUrl;
        final name = episodes?.firstOrNull?.podcastTitle ?? '';
        await di<SubscribedPodcastsManager>().command.runAsync(
          PodcastToggleCapsule(
            feedUrl: podcast.feedUrl,
            imageUrl: imageUrl,
            name: name,
            artist: artist,
          ),
        );
      }
    }
  }

  Future<bool> exportPodcastsToOpmlFile() async {
    final location = await _externalPathService.getPathOfDirectory();
    if (location == null) {
      return false;
    }

    final file = File('$location/podcasts.opml');
    if (file.existsSync()) {
      file.deleteSync();
    }
    final head = OpmlHeadBuilder().title('Podcasts').build();
    final body = <OpmlOutline>[];
    final category = OpmlOutlineBuilder();

    for (var feedUrl in (await _subscribedPodcastsManager.command.runAsync())) {
      final shortInfo = di<PodcastShortInfoManager>(
        param1: feedUrl,
      ).command.value;
      final name = shortInfo?.name;
      final artist = shortInfo?.artist;
      final builder = OpmlOutlineBuilder().type('rss').xmlUrl(feedUrl);
      if (name != null) {
        builder.title(name);
      }
      if (artist != null) {
        builder.text(artist);
      }
      category.addChild(builder.build());
    }

    body.add(category.type('rss').title('Podcasts').text('Podcasts').build());

    final opml = OpmlDocument(head: head, body: body);
    final xml = opml.toXmlString(pretty: true);
    file.writeAsStringSync(xml);

    return true;
  }

  Future<bool> exportStarredStationsToOpmlFile() async {
    final location = await _externalPathService.getPathOfDirectory();
    if (location == null) {
      return false;
    }

    final file = File('$location/starred_stations.opml');
    if (file.existsSync()) {
      file.deleteSync();
    }
    final head = OpmlHeadBuilder().title('Starred Stations').build();
    final body = <OpmlOutline>[];
    final category = OpmlOutlineBuilder();

    for (var station in await _radioService.getStarredStations()) {
      category.addChild(OpmlOutlineBuilder().text(station).build());
    }

    body.add(
      category.title('Starred Stations').text('Starred Stations').build(),
    );

    final opml = OpmlDocument(head: head, body: body);
    final xml = opml.toXmlString(pretty: true);
    file.writeAsStringSync(xml);

    return true;
  }

  Future<void> importStarredStationsFromOpmlFile() async {
    final path = await _externalPathService.getPathOfFile();

    if (path == null) {
      return;
    }
    final file = File(path);
    if (!file.existsSync()) return;
    final xml = file.readAsStringSync();
    final doc = OpmlDocument.parse(xml);

    for (var category in doc.body.where((e) => e.children != null)) {
      final children = category.children!.where((e) => e.text != null);
      final starredStations = <String>[];
      for (var feed in children) {
        starredStations.add(feed.text!);
      }
      if (starredStations.isNotEmpty) {
        for (final uuid in starredStations) {
          final station = await di<RadioManager>().getAudioByUUID(uuid);
          await di<RadioStarStationManager>().command.runAsync(station);
        }
      }
    }
  }

  final playlistName = SafeValueNotifier<String?>(null);
  void setPlaylistName(String? value) {
    if (playlistName.value == value) return;
    playlistName.value = value;
  }
}

Future<List<Audio>> _parseM3uPlaylist(String path) async {
  final audios = <Audio>[];
  final playlist = await compute(M3uList.loadFromFile, path);

  for (var e in playlist.items) {
    if (e.link.startsWith('http')) {
      audios.add(
        Audio(
          title: e.title,
          url: e.link,
          description: e.link,
          audioType: AudioType.radio,
        ),
      );
    } else if (e.link.isNotEmpty) {
      final file = File(e.link.replaceAll('file://', ''));
      if (file.existsSync() && file.isPlayable) {
        audios.add(Audio.local(file));
      }
    }
  }

  return audios;
}

Future<List<Audio>> _parsePlsPlaylist(String path) async {
  final audios = <Audio>[];
  final playlist = PlsPlaylist.parse(File(path).readAsStringSync());

  for (var e in playlist.entries) {
    if (e.file?.startsWith('http') == true) {
      audios.add(
        Audio(
          title: e.title,
          url: e.file,
          description: e.file,
          audioType: AudioType.radio,
        ),
      );
    } else if (e.file?.isNotEmpty == true) {
      final file = File(e.file!);
      if (file.existsSync() && file.isPlayable) {
        audios.add(Audio.local(file));
      }
    }
  }

  return audios;
}
