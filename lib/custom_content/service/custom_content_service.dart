import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injectable/injectable.dart';
import 'package:m3u_parser_nullsafe/m3u_parser_nullsafe.dart';
import 'package:opml/opml.dart';
import 'package:path/path.dart';
import 'package:pls/pls.dart';

import '../../common/data/audio.dart';
import '../../common/data/audio_type.dart';
import '../../common/logging.dart';
import '../../dependencies.dart';
import '../../extensions/media_file_x.dart';
import '../../external_path/service/external_path_service.dart';
import '../../local_audio/service/local_audio_service.dart';
import '../../podcasts/service/podcast_service.dart';
import '../../radio/manager/radio_manager.dart';
import '../../radio/manager/radio_star_station_manager.dart';
import '../../radio/service/radio_service.dart';

@lazySingleton
class CustomContentService {
  CustomContentService({
    required ExternalPathService externalPathService,
    required LocalAudioService localAudioService,
    required PodcastService podcastService,
    required RadioService radioService,
  }) : _externalPathService = externalPathService,
       _localAudioService = localAudioService,
       _podcastService = podcastService,
       _radioService = radioService;

  final ExternalPathService _externalPathService;
  final LocalAudioService _localAudioService;
  final PodcastService _podcastService;
  final RadioService _radioService;

  Future<Map<String, List<Audio>>> loadPlaylistsFromFiles() async {
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
      Logger.e(e, trace: s, tag: '$CustomContentService');
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
    for (var e in (await _localAudioService.findPinnedAlbumIDs())) {
      albums.add((
        id: e.toString(),
        audios: await _localAudioService.findAlbum(e) ?? [],
      ));
    }

    final playlistIds = await _localAudioService.findAllPlaylistIDs();
    final playlists = <({String id, List<Audio> audios})>[];
    for (var id in playlistIds) {
      playlists.add((
        id: id,
        audios: await _localAudioService.findPlaylistById(id) ?? [],
      ));
    }

    final List<({String id, List<Audio> audios})> list = [
      ...playlists,
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
      Logger.e(e, trace: s, tag: '$CustomContentService');
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
        await _podcastService.togglePodcastSubscription(
          feedUrl: podcast.feedUrl,
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

    for (var feedUrl in (await _podcastService.getSubscribedPodcasts())) {
      final shortInfo = await _podcastService.getPodcastShortInfo(feedUrl);
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
          final station = di.isRegistered<ProviderContainer>()
              ? await di<ProviderContainer>()
                  .read(radioManagerProvider.notifier)
                  .getAudioByUUID(uuid)
              : await _radioService.getAudioByUUID(uuid, fromDBOnly: false);
          if (station != null) {
            await _radioService.toggleStarredStation(station);
          }
        }
        if (di.isRegistered<ProviderContainer>()) {
          di<ProviderContainer>().invalidate(radioStarStationManagerProvider);
        }
      }
    }
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
